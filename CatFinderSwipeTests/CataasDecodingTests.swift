import Foundation
import Testing
@testable import CatFinderSwipe

struct CataasDecodingTests {
    @Test
    func decodesCataasResponse() throws {
        let json = #"{"id":"abc123","tags":["cute"],"created_at":"2024-06-19T17:03:38.483Z","url":"https://cataas.com/cat/abc123?position=center","mimetype":"image/jpeg"}"#
        let data = Data(json.utf8)

        let decoded = try JSONDecoder().decode(CataasCatResponse.self, from: data)
        #expect(decoded.id == "abc123")
        #expect(decoded.url.contains("cataas.com/cat/abc123"))
    }
}
