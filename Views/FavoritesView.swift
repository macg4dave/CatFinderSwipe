import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteCat.createdAt, order: .reverse) private var favorites: [FavoriteCat]

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 110), spacing: 12, alignment: .top)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(favorites) { fav in
                    if let url = fav.imageURL {
                        NavigationLink {
                            FavoriteDetailView(imageURL: url)
                        } label: {
                            CachedAsyncImageView(url: url, contentMode: .fill)
                                .frame(height: 110)
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
            .padding()
        }
        .navigationTitle("Favorites")
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
