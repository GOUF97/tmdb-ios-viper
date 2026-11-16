import Foundation

public enum NetworkError: LocalizedError, Equatable, Sendable {
    case invalidURL
    case noInternetConnection
    case unauthorized
    case resourceNotFound
    case serverError(statusCode: Int, message: String?)
    case decodingError(String)
    case emptyData
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .noInternetConnection:
            return "No internet connection detected. Please check your network and try again."
        case .unauthorized:
            return "Invalid or missing TMDb API key. Please check your API credentials."
        case .resourceNotFound:
            return "The requested resource could not be found."
        case .serverError(let statusCode, let message):
            if let msg = message, !msg.isEmpty {
                return "Server error (\(statusCode)): \(msg)"
            }
            return "Server responded with error status code: \(statusCode)."
        case .decodingError(let details):
            return "Failed to parse data from server: \(details)"
        case .emptyData:
            return "No data was returned from the server."
        case .unknown(let message):
            return message
        }
    }
}
