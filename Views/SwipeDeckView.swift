import SwiftUI
import SwiftData

struct SwipeDeckView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.displayScale) private var displayScale

    @StateObject private var viewModel: SwipeDeckViewModel

    @State private var dragOffset: CGSize = .zero

    // Swipe animation overlay (prevents the current card from changing content mid-swipe).
    @State private var swipingCard: CatCard?
    @State private var swipeOverlayOffset: CGSize = .zero
    @State private var isSwipeAnimating: Bool = false

    // Milestone 7: fun feedback.
    @State private var likeBurstTrigger: Int = 0
    @State private var nopeBurstTrigger: Int = 0

    private enum Layout {
        static let cardWidthFraction: CGFloat = 0.95
        static let cardHeightFraction: CGFloat = 0.90
        static let cardCornerRadius: CGFloat = 20
        static let swipeThreshold: CGFloat = 120
        static let swipeAnimationDuration: TimeInterval = 0.22
    }

    init(api: CatAPIClientProtocol = CataasAPIClient()) {
        // ModelContext is only available at runtime, so we build the store in init using the environment later.
        // We initialize with a lightweight placeholder store; it’ll be replaced on appear.
        let placeholderContainer = try? ModelContainer(for: Schema([FavoriteCat.self, SeenCat.self]), configurations: [])
        let placeholderContext = placeholderContainer.map { ModelContext($0) } ?? ModelContext(try! ModelContainer(for: Schema([FavoriteCat.self, SeenCat.self])))
        _viewModel = StateObject(wrappedValue: SwipeDeckViewModel(api: api, store: CatDecisionStore(modelContext: placeholderContext)))
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            content
                .padding()

            // Emoji bursts (non-interactive overlay).
            EmojiBurstView(trigger: likeBurstTrigger, kind: .happy, direction: .up)
                .zIndex(10)
            EmojiBurstView(trigger: nopeBurstTrigger, kind: .sad, direction: .down)
                .zIndex(10)

            if viewModel.isOffline {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "wifi.slash")
                        Text("Offline")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Connect and tap Retry")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(.quaternary)
                    )
                    .padding(.top, 10)

                    Spacer()
                }
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            NavigationLink {
                FavoritesView()
            } label: {
                Label("Favorites", systemImage: "heart.fill")
            }

#if DEBUG
            Button {
                viewModel.clearDataAndReload()
            } label: {
                Label("Clear Data", systemImage: "trash")
            }
#endif
        }
        .onAppear {
            // Swap in the real store backed by the app’s ModelContext.
            viewModel.replaceStore(CatDecisionStore(modelContext: modelContext))
            viewModel.start()
        }
    }

    @ViewBuilder
    private var content: some View {
        if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 12) {
                ContentUnavailableView("Couldn’t load cats", systemImage: "wifi.exclamationmark", description: Text(errorMessage))
                Button("Retry") { viewModel.retry() }
                    .buttonStyle(.borderedProminent)
            }
        } else if viewModel.isLoading && viewModel.current == nil {
            ProgressView("Loading cats…")
        } else if let current = viewModel.current {
            GeometryReader { proxy in
                let cardWidth = proxy.size.width * Layout.cardWidthFraction
                let cardHeight = proxy.size.height * Layout.cardHeightFraction
                let shape = RoundedRectangle(cornerRadius: Layout.cardCornerRadius, style: .continuous)

                // Provide the view model a pixel-size hint so prefetch warms the right cache variant.
                let maxPoints = max(cardWidth, cardHeight)
                let rawPixels = Int(ceil(maxPoints * displayScale))
                let clampedPixels = max(256, min(2048, rawPixels))
                let bucket = 128
                let pixelBucket = ((clampedPixels + bucket - 1) / bucket) * bucket

                ZStack {
                    if let next = viewModel.next {
                        CatCardView(card: next, backgroundColor: viewModel.backgroundColor)
                            .frame(width: cardWidth, height: cardHeight)
                            .clipShape(shape)
                            .contentShape(shape)
                            .overlay(shape.strokeBorder(.quaternary))
                            .scaleEffect(0.98)
                            .opacity(0.6)
                    }

                    // Underlying interactive card (this is always the *current* card).
                    CatCardView(card: current, backgroundColor: viewModel.backgroundColor)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipShape(shape)
                        .contentShape(shape)
                        .overlay(shape.strokeBorder(.quaternary))
                        .offset(dragOffset)
                        .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    guard !isSwipeAnimating else { return }
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    guard !isSwipeAnimating else { return }
                                    handleDragEnded(value, containerWidth: proxy.size.width)
                                }
                        )

                    // Swipe overlay sits above the deck while animating out.
                    if let swipingCard {
                        CatCardView(card: swipingCard, backgroundColor: viewModel.backgroundColor)
                            .frame(width: cardWidth, height: cardHeight)
                            .clipShape(shape)
                            .contentShape(shape)
                            .overlay(shape.strokeBorder(.quaternary))
                            .offset(swipeOverlayOffset)
                            .rotationEffect(.degrees(Double(swipeOverlayOffset.width / 20)))
                            .allowsHitTesting(false)
                            .zIndex(5)
                    }
                }
                .onAppear {
                    viewModel.updatePrefetchMaxPixelSize(pixelBucket)
                }
                .onChange(of: proxy.size) { _, _ in
                    viewModel.updatePrefetchMaxPixelSize(pixelBucket)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: dragOffset)
        } else {
            ContentUnavailableView("No cats", systemImage: "cat")
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value, containerWidth: CGFloat) {
        let translation = value.translation

        let offscreenX = max(600, containerWidth * 1.25)

        if translation.width > Layout.swipeThreshold {
            // Capture the current card into an overlay so it can animate out without changing content.
            swipingCard = viewModel.current
            swipeOverlayOffset = translation
            isSwipeAnimating = true

            // Immediately reset the interactive card position (the deck will advance under the overlay).
            dragOffset = .zero

            withAnimation(.easeOut(duration: Layout.swipeAnimationDuration)) {
                swipeOverlayOffset = CGSize(width: offscreenX, height: translation.height)
            }

            Haptics.swipeCommitLike()
            likeBurstTrigger += 1
            viewModel.swipeRight()

            DispatchQueue.main.asyncAfter(deadline: .now() + Layout.swipeAnimationDuration) {
                swipingCard = nil
                swipeOverlayOffset = .zero
                isSwipeAnimating = false
            }
        } else if translation.width < -Layout.swipeThreshold {
            swipingCard = viewModel.current
            swipeOverlayOffset = translation
            isSwipeAnimating = true

            dragOffset = .zero

            withAnimation(.easeOut(duration: Layout.swipeAnimationDuration)) {
                swipeOverlayOffset = CGSize(width: -offscreenX, height: translation.height)
            }

            Haptics.swipeCommitNope()
            nopeBurstTrigger += 1
            viewModel.swipeLeft()

            DispatchQueue.main.asyncAfter(deadline: .now() + Layout.swipeAnimationDuration) {
                swipingCard = nil
                swipeOverlayOffset = .zero
                isSwipeAnimating = false
            }
        } else {
            withAnimation { dragOffset = .zero }
        }
    }
}

#Preview {
    NavigationStack {
        SwipeDeckView()
    }
    .modelContainer(for: [FavoriteCat.self, SeenCat.self], inMemory: true)
}
