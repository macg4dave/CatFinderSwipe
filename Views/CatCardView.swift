import SwiftUI

struct CatCardView: View {
    let card: CatCard
    let backgroundColor: Color

    var onLike: (() -> Void)? = nil
    var onSkip: (() -> Void)? = nil
    var onUndo: (() -> Void)? = nil

    init(
        card: CatCard,
        backgroundColor: Color = StableColor.color(for: UUID().uuidString),
        onLike: (() -> Void)? = nil,
        onSkip: (() -> Void)? = nil,
        onUndo: (() -> Void)? = nil
    ) {
        self.card = card
        self.backgroundColor = backgroundColor
        self.onLike = onLike
        self.onSkip = onSkip
        self.onUndo = onUndo
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

        ZStack {
            backgroundColor

            CachedAsyncImageView(url: card.imageURL, contentMode: .fill)
        }
        .clipShape(shape)
        .contentShape(shape)
        .overlay(shape.strokeBorder(.quaternary))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Cat photo")
        .accessibilityHint("Swipe right to favorite. Swipe left to skip.")
        .accessibilityAction(named: "Favorite") {
            onLike?()
        }
        .accessibilityAction(named: "Skip") {
            onSkip?()
        }
        .accessibilityAction(named: "Undo") {
            onUndo?()
        }
    }
}
