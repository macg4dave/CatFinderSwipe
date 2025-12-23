import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteCat.createdAt, order: .reverse) private var favorites: [FavoriteCat]

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
                                FavoriteDetailView(imageURL: url)
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
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, spacing)
            }
            .navigationTitle("Favorites")
        }
    }
}

struct FavoriteDetailView: View {
    let imageURL: URL

    var body: some View {
        VStack {
            CachedAsyncImageView(url: imageURL, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding()
    }
}
