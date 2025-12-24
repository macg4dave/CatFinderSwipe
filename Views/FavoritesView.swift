import SwiftUI
import SwiftData
import UIKit

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteCat.createdAt, order: .reverse) private var favorites: [FavoriteCat]

    @State private var isPreparingShare: Bool = false
    @State private var shareURL: URL?
    @State private var isShowingShareSheet: Bool = false
    @State private var shareErrorMessage: String?

    private let spacing: CGFloat = 12
    private let horizontalPadding: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let availableWidth = max(0, geo.size.width - (horizontalPadding * 2))
            let columnsCount = max(2, Int(availableWidth / 140))
            let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: spacing, alignment: .top), count: columnsCount)
            let tileSize = (availableWidth - (CGFloat(columnsCount - 1) * spacing)) / CGFloat(columnsCount)

            ScrollView {
                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(favorites) { fav in
                        if let url = fav.imageURL {
                            NavigationLink {
                                FavoriteDetailView(favorite: fav)
                            } label: {
                                CachedAsyncImageView(url: url, contentMode: .fill)
                                    .frame(width: tileSize, height: tileSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(.quaternary)
                                    )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    Task {
                                        await prepareShareFromGrid(url: url, id: fav.id)
                                    }
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }

                                Button(role: .destructive) {
                                    modelContext.delete(fav)
                                    WidgetFavoritesExport.exportFavorites(modelContext: modelContext)
                                } label: {
                                    Label("Remove from Favorites", systemImage: "heart.slash")
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, spacing)
            }
            .navigationTitle("Favorites")
            .sheet(isPresented: $isShowingShareSheet, onDismiss: cleanupTempShareFile) {
                if let shareURL {
                    ShareSheet(activityItems: [shareURL])
                }
            }
            .overlay(alignment: .bottom) {
                if let shareErrorMessage {
                    Text(shareErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(.quaternary)
                        )
                        .padding(.bottom, 16)
                        .transition(.opacity)
                }
            }
        }
    }

    @MainActor
    private func prepareShareFromGrid(url: URL, id: String) async {
        shareErrorMessage = nil
        guard !isPreparingShare else { return }
        isPreparingShare = true
        defer { isPreparingShare = false }

        do {
            let image = try await ImagePipeline.shared.image(for: url, maxPixelSize: 2048)
            guard let data = image.jpegData(compressionQuality: 0.92) ?? image.pngData() else {
                shareErrorMessage = "Couldn’t prepare image data for sharing."
                return
            }

            let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let fileName = "CatFinderSwipe-\(id).jpg"
            let fileURL = tempDir.appendingPathComponent(fileName)
            try data.write(to: fileURL, options: [.atomic])

            shareURL = fileURL
            isShowingShareSheet = true
        } catch {
            shareErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func cleanupTempShareFile() {
        guard let shareURL else { return }
        try? FileManager.default.removeItem(at: shareURL)
        self.shareURL = nil
        // Auto-clear error after a bit? Keep it simple: clear immediately.
        self.shareErrorMessage = nil
    }
}

struct FavoriteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let favorite: FavoriteCat

    @State private var isPreparingShare: Bool = false
    @State private var shareURL: URL?
    @State private var isShowingShareSheet: Bool = false
    @State private var shareErrorMessage: String?

    var body: some View {
        VStack {
            if let imageURL = favorite.imageURL {
                CachedAsyncImageView(url: imageURL, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                ContentUnavailableView("Missing image", systemImage: "photo", description: Text("This favorite doesn't have a valid image URL."))
            }

            if let shareErrorMessage {
                Text(shareErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding()
        .navigationTitle("Favorite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isPreparingShare {
                ProgressView()
            } else {
                Button {
                    Task { await prepareShare() }
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .disabled(favorite.imageURL == nil)
            }

            Button(role: .destructive) {
                modelContext.delete(favorite)
                WidgetFavoritesExport.exportFavorites(modelContext: modelContext)
                dismiss()
            } label: {
                Label("Unfavorite", systemImage: "heart.slash")
            }
        }
        .sheet(isPresented: $isShowingShareSheet, onDismiss: cleanupTempShareFile) {
            if let shareURL {
                ShareSheet(activityItems: [shareURL])
            }
        }
    }

    @MainActor
    private func prepareShare() async {
        shareErrorMessage = nil
        guard let imageURL = favorite.imageURL else {
            shareErrorMessage = "No image URL available to share."
            return
        }

        isPreparingShare = true
        defer { isPreparingShare = false }

        do {
            // Fetch a reasonably high-quality image for sharing.
            // (We still downsample in the pipeline to avoid huge textures.)
            let image = try await ImagePipeline.shared.image(for: imageURL, maxPixelSize: 2048)

            guard let data = image.jpegData(compressionQuality: 0.92) ?? image.pngData() else {
                shareErrorMessage = "Couldn’t prepare image data for sharing."
                return
            }

            let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let fileName = "CatFinderSwipe-\(favorite.id).jpg"
            let fileURL = tempDir.appendingPathComponent(fileName)
            try data.write(to: fileURL, options: [.atomic])

            shareURL = fileURL
            isShowingShareSheet = true
        } catch {
            shareErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func cleanupTempShareFile() {
        guard let shareURL else { return }
        try? FileManager.default.removeItem(at: shareURL)
        self.shareURL = nil
        self.shareErrorMessage = nil
    }
}
