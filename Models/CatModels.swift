import Foundation
import SwiftData

@Model
final class FavoriteCat {
    @Attribute(.unique) var id: String
    var imageURLString: String
    var createdAt: Date

    init(id: String, imageURL: URL, createdAt: Date = Date()) {
        self.id = id
        self.imageURLString = imageURL.absoluteString
        self.createdAt = createdAt
    }

    var imageURL: URL? { URL(string: imageURLString) }
}

@Model
final class SeenCat {
    @Attribute(.unique) var id: String
    var imageURLString: String
    var createdAt: Date

    init(id: String, imageURL: URL, createdAt: Date = Date()) {
        self.id = id
        self.imageURLString = imageURL.absoluteString
        self.createdAt = createdAt
    }

    var imageURL: URL? { URL(string: imageURLString) }
}
