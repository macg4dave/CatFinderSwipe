import Foundation

protocol CatAPIClientProtocol {
    func fetchNextCat() async throws -> CatCard
}

enum CatAPIError: Error, LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid server response."
        case .httpStatus(let code): return "Server returned HTTP \(code)."
        case .invalidURL: return "Invalid URL."
        }
    }
}

final class CataasAPIClient: CatAPIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchNextCat() async throws -> CatCard {
        guard let url = URL(string: "https://cataas.com/cat?json=true") else {
            throw CatAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw CatAPIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw CatAPIError.httpStatus(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(CataasCatResponse.self, from: data)
        guard let imageURL = URL(string: decoded.url) else {
            throw CatAPIError.invalidURL
        }

        return CatCard(id: decoded.id, imageURL: imageURL, source: "cataas")
    }
}
