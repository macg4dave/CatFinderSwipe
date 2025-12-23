import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteCat.createdAt, order: .reverse) private var favorites: [FavoriteCat]

    var body: some View {
        List {
            ForEach(favorites) { fav in
                if let url = fav.imageURL {
                    NavigationLink {
                        FavoriteDetailView(imageURL: url)
                    } label: {
                        HStack {
                            CachedAsyncImageView(url: url, contentMode: .fill)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            Text(fav.id)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .navigationTitle("Favorites")
    }
}

struct FavoriteDetailView: View {
    let imageURL: URL

    var body: some View {
        VStack {
            CachedAsyncImageView(url: imageURL, contentMode: .fit)
        }
        .padding()
    }
}
