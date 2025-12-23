import SwiftUI

struct CatCardView: View {
    let card: CatCard
    let backgroundColor: Color

    init(card: CatCard, backgroundColor: Color = StableColor.color(for: UUID().uuidString)) {
        self.card = card
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

        ZStack {
            backgroundColor

            CachedAsyncImageView(url: card.imageURL, contentMode: .fill)
                .clipped()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(shape)
        .contentShape(shape)
        .overlay(shape.strokeBorder(.quaternary))
        .accessibilityLabel("Cat photo")
    }
}
