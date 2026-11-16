import Foundation

public struct Genre: Codable, Hashable, Identifiable, Sendable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct GenreResponse: Codable, Sendable {
    public let genres: [Genre]

    public init(genres: [Genre]) {
        self.genres = genres
    }
}
