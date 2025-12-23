import Foundation

/// A normalized model used by the swipe deck.
struct CatCard: Identifiable, Equatable, Hashable {
    let id: String
    let imageURL: URL
    let source: String

    init(id: String, imageURL: URL, source: String) {
        self.id = id
        self.imageURL = imageURL
        self.source = source
    }
}
