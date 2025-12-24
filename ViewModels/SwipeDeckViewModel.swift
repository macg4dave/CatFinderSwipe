import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class SwipeDeckViewModel: ObservableObject {
    @Published private(set) var current: CatCard?
    @Published private(set) var next: CatCard?

    /// Debug/telemetry-friendly: how many cards are currently buffered (including `current`).
    @Published private(set) var bufferedCount: Int = 0

    @Published private(set) var backgroundColor: Color = StableColor.color(for: "initial")

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var isOffline: Bool = false

    private let api: CatAPIClientProtocol
    private var store: CatDecisionStore

    private let networkMonitor: NetworkMonitor
    private var cancellables: Set<AnyCancellable> = []

    private enum Buffering {
        /// How many cards ahead we try to keep ready to avoid network churn during rapid swipes.
        static let aheadCount: Int = 10
        /// Total buffer size including the current card.
        static var targetCount: Int { 1 + aheadCount }
    }

    /// Internal buffer. Index 0 = current, index 1 = next, the rest are queued.
    private var buffer: [CatCard] = []

    private var fillBufferTask: Task<Void, Never>?
    private var prefetchTask: Task<Void, Never>?

    /// Optional size hint so prefetch uses the same cache variant as the on-screen card.
    private var prefetchMaxPixelSize: Int?

    init(api: CatAPIClientProtocol, store: CatDecisionStore, networkMonitor: NetworkMonitor? = nil) {
        self.api = api
        self.store = store
        self.networkMonitor = networkMonitor ?? NetworkMonitor()

        // Keep a simple offline flag for UI messaging.
        self.networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isOffline = !connected
            }
            .store(in: &cancellables)
    }

    func replaceStore(_ store: CatDecisionStore) {
        self.store = store
    }

    func start() {
        Task { await ensureLoaded() }
    }

    func updatePrefetchMaxPixelSize(_ maxPixelSize: Int?) {
        prefetchMaxPixelSize = maxPixelSize
        // Kick a new prefetch using the updated size hint.
        prefetchImagesForDeck()
    }

    func retry() {
        errorMessage = nil
        Task { await ensureLoaded(force: true) }
    }

    func clearDataAndReload() {
        Task {
            // Clear persistence.
            store.clearAll()

            // Clear caches.
            prefetchTask?.cancel()
            prefetchTask = nil
            ImagePipeline.shared.clearMemory()
            await ImagePipeline.shared.clearDisk()

            // Reset UI state and reload.
            current = nil
            next = nil
            errorMessage = nil
            isLoading = false
            backgroundColor = StableColor.color(for: UUID().uuidString)
            await ensureLoaded(force: true)
        }
    }

    private func ensureLoaded(force: Bool = false) async {
        guard force || current == nil else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            if isOffline {
                throw OfflineError()
            }
            // Reset buffer on a forced reload.
            if force {
                fillBufferTask?.cancel()
                fillBufferTask = nil
                buffer.removeAll(keepingCapacity: true)
            }

            try await fillBufferIfNeeded(upTo: Buffering.targetCount)
            syncPublishedCardsFromBuffer()

            // Background to be a random solid colour on every swipe / initial load.
            backgroundColor = StableColor.color(for: UUID().uuidString)

            // Prefetch next image to keep swiping snappy.
            prefetchImagesForDeck()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func fetchNonSeenCard(excluding excludedIds: Set<String> = []) async throws -> CatCard {
        if isOffline {
            throw OfflineError()
        }
        var attempts = 0
        while attempts < 40 {
            attempts += 1
            let card = try await api.fetchNextCat()
            if excludedIds.contains(card.id) { continue }
            if store.isSeen(id: card.id) { continue }
            return card
        }
        return try await api.fetchNextCat()
    }

    func swipeLeft() {
        guard let current else { return }
        store.markSeen(current)
        advanceDeck()
    }

    func swipeRight() {
        guard let current else { return }
        store.addFavorite(current)
        store.markSeen(current)
        advanceDeck()
    }

    private func advanceDeck() {
        // Drop the current card from the front of the buffer.
        if !buffer.isEmpty {
            buffer.removeFirst()
        }

        syncPublishedCardsFromBuffer()

        // Background to be a random solid colour on every swipe.
        backgroundColor = StableColor.color(for: UUID().uuidString)

        // Top up and prefetch after the deck advances.
        ensureBufferTopUpAndPrefetch()
    }

    private func ensureBufferTopUpAndPrefetch() {
        if buffer.count >= Buffering.targetCount {
            prefetchImagesForDeck()
            return
        }

        // Avoid spawning redundant fetch tasks when the user swipes quickly.
        guard fillBufferTask == nil else {
            prefetchImagesForDeck()
            return
        }

        // If the user somehow outruns the buffer, surface a loading state instead of a blank deck.
        if buffer.isEmpty {
            isLoading = true
        }

        fillBufferTask = Task { [weak self] in
            guard let self else { return }
            defer {
                Task { @MainActor in
                    self.fillBufferTask = nil
                }
            }

            do {
                try await self.fillBufferIfNeeded(upTo: Buffering.targetCount)
                await MainActor.run {
                    self.syncPublishedCardsFromBuffer()
                    self.prefetchImagesForDeck()
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func fillBufferIfNeeded(upTo targetCount: Int) async throws {
        guard !isOffline else { throw OfflineError() }
        guard targetCount > 0 else { return }

        // Keep fetching until we have enough unique, non-seen cards.
        while buffer.count < targetCount {
            if Task.isCancelled { return }
            let excluded = Set(buffer.map { $0.id })
            let card = try await fetchNonSeenCard(excluding: excluded)
            if excluded.contains(card.id) { continue }
            if store.isSeen(id: card.id) { continue }
            buffer.append(card)
        }
    }

    private func syncPublishedCardsFromBuffer() {
        current = buffer.first
        next = buffer.count > 1 ? buffer[1] : nil
        bufferedCount = buffer.count
    }

    private func prefetchImagesForDeck() {
        // Cancel any in-flight prefetch to prioritize the newest "next".
        prefetchTask?.cancel()
        prefetchTask = Task {
            // Warm the cache for the current card as well.
            // Prefetch up to current + 10 ahead.
            let urls: [URL] = await MainActor.run {
                Array(self.buffer.prefix(Buffering.targetCount)).map { $0.imageURL }
            }

            for url in urls {
                if Task.isCancelled { return }
                await ImagePipeline.shared.prefetch(url, maxPixelSize: await MainActor.run { self.prefetchMaxPixelSize })
            }
        }
    }
}

private struct OfflineError: LocalizedError {
    var errorDescription: String? {
        "You appear to be offline. Connect to the internet and tap Retry."
    }
}
