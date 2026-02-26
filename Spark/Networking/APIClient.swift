import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(endpoint: Constants.Endpoints,
                               method: APIClient.HTTPMethod,
                               parameters: [String: Any]?) async throws -> T
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()
    private init() {}
    
    private let decoder = JSONDecoder()
    
    func request<T: Decodable>(endpoint: Constants.Endpoints,
                               method: HTTPMethod = .GET,
                               parameters: [String: Any]? = nil) async throws -> T {
        
        do {
            guard var components = URLComponents(string: endpoint.url) else { throw APIError.invalidURL }
            
            if method == .GET, let params = parameters {
                components.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            }
            
            guard let url = components.url else { throw APIError.invalidURL }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.timeoutInterval = Constants.API.timeout
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if method != .GET, let params = parameters {
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200...299).contains(httpResponse.statusCode) else { throw APIError.serverError(httpResponse.statusCode) }
            guard !data.isEmpty else { throw APIError.noData }
            
            return try decoder.decode(T.self, from: data)
        } catch {
            throw error
        }
    }
}

extension APIClient {
    
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE, PATCH
    }
    
    enum APIError: Error {
        case invalidURL
        case networkError(String)
        case invalidResponse
        case serverError(Int)
        case noData
        case decodingError(String)
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .networkError(let message):
                return "Network error: \(message)"
            case .invalidResponse:
                return "Invalid server response"
            case .serverError(let code):
                return "Server error with status code \(code)"
            case .noData:
                return "No data received"
            case .decodingError(let message):
                return "Failed to decode response: \(message)"
            }
        }
    }
}
