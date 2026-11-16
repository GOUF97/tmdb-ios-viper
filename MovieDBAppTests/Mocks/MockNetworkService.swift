import Foundation
@testable import MovieDBApp

public final class MockNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    public var resultToReturn: Any?
    public var errorToThrow: Error?
    public private(set) var requestedEndpoints: [Endpoint] = []

    public init() {}

    public func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        requestedEndpoints.append(endpoint)

        if let error = errorToThrow {
            throw error
        }

        if let result = resultToReturn as? T {
            return result
        }

        throw NetworkError.unknown("Mock result not provided or type mismatch.")
    }
}
