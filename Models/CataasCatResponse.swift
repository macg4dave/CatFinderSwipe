import Foundation

/// Decoding model for the Cataas API `https://cataas.com/cat?json=true`.
///
/// Example keys are typically: `_id`, `id`, and `url`.
struct CataasCatResponse: Decodable {
    let id: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let id = try? container.decode(String.self, forKey: .id) {
            self.id = id
        } else {
            self.id = try container.decode(String.self, forKey: ._id)
        }

        self.url = try container.decode(String.self, forKey: .url)
    }
}
