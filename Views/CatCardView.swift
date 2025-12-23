import SwiftUI

struct CatCardView: View {
    let card: CatCard
    let backgroundColor: Color

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

        ZStack {
            backgroundColor

            CachedAsyncImageView(url: card.imageURL, contentMode: .fill)
        }
        .clipShape(shape)
        .overlay(shape.strokeBorder(.quaternary))
        .accessibilityLabel("Cat photo")
    }
}
