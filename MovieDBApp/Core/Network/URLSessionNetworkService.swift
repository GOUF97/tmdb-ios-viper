import Foundation

public final class URLSessionNetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        request.timeoutInterval = 30

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .timedOut:
                throw NetworkError.noInternetConnection
            default:
                throw NetworkError.unknown(urlError.localizedDescription)
            }
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Unexpected response format.")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Attempt to parse TMDb error response payload
            let serverMessage = parseServerErrorMessage(from: data)

            switch httpResponse.statusCode {
            case 401:
                throw NetworkError.unauthorized
            case 404:
                throw NetworkError.resourceNotFound
            default:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: serverMessage)
            }
        }

        guard !data.isEmpty else {
            throw NetworkError.emptyData
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            let details = describeDecodingError(decodingError)
            throw NetworkError.decodingError(details)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }

    private func parseServerErrorMessage(from data: Data) -> String? {
        struct TMDbErrorResponse: Decodable {
            let statusMessage: String?
            let success: Bool?
        }
        return try? decoder.decode(TMDbErrorResponse.self, from: data).statusMessage
    }

    private func describeDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            return "Type mismatch for '\(type)': \(context.debugDescription) (CodingPath: \(context.codingPath.map(\.stringValue).joined(separator: ".")))"
        case .valueNotFound(let type, let context):
            return "Value '\(type)' not found: \(context.debugDescription) (CodingPath: \(context.codingPath.map(\.stringValue).joined(separator: ".")))"
        case .keyNotFound(let key, let context):
            return "Key '\(key.stringValue)' not found: \(context.debugDescription) (CodingPath: \(context.codingPath.map(\.stringValue).joined(separator: ".")))"
        case .dataCorrupted(let context):
            return "Data corrupted: \(context.debugDescription)"
        @unknown default:
            return "Unknown decoding failure."
        }
    }
}
