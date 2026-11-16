import Foundation

public struct MovieDetail: Codable, Sendable {
    public let id: Int
    public let title: String
    public let overview: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let runtime: Int?
    public let voteAverage: Double?
    public let voteCount: Int?
    public let genres: [Genre]?
    public let tagline: String?

    public init(
        id: Int,
        title: String,
        overview: String? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        releaseDate: String? = nil,
        runtime: Int? = nil,
        voteAverage: Double? = nil,
        voteCount: Int? = nil,
        genres: [Genre]? = nil,
        tagline: String? = nil
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.genres = genres
        self.tagline = tagline
    }

    public var formattedRating: String {
        guard let rating = voteAverage, rating > 0 else { return "N/A" }
        return String(format: "%.1f", rating)
    }

    public var releaseYear: String {
        guard let releaseDate = releaseDate, releaseDate.count >= 4 else { return "" }
        return String(releaseDate.prefix(4))
    }

    public var formattedRuntime: String {
        guard let minutes = runtime, minutes > 0 else { return "" }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        }
        return "\(remainingMinutes)m"
    }

    public var genreNames: String {
        genres?.map(\.name).joined(separator: " • ") ?? ""
    }
}

public struct UserReview: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let author: String
    public let content: String
    public let createdAt: String?
    public let authorDetails: AuthorDetails?

    public struct AuthorDetails: Codable, Hashable, Sendable {
        public let name: String?
        public let username: String?
        public let rating: Double?
        public let avatarPath: String?

        public init(name: String? = nil, username: String? = nil, rating: Double? = nil, avatarPath: String? = nil) {
            self.name = name
            self.username = username
            self.rating = rating
            self.avatarPath = avatarPath
        }
    }

    public init(id: String, author: String, content: String, createdAt: String? = nil, authorDetails: AuthorDetails? = nil) {
        self.id = id
        self.author = author
        self.content = content
        self.createdAt = createdAt
        self.authorDetails = authorDetails
    }
}

public struct ReviewResponse: Codable, Sendable {
    public let id: Int
    public let page: Int
    public let results: [UserReview]
    public let totalPages: Int
    public let totalResults: Int

    public init(id: Int, page: Int, results: [UserReview], totalPages: Int, totalResults: Int) {
        self.id = id
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }
}

public struct MovieVideo: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let key: String
    public let name: String
    public let site: String
    public let type: String
    public let official: Bool?

    public init(id: String, key: String, name: String, site: String, type: String, official: Bool? = nil) {
        self.id = id
        self.key = key
        self.name = name
        self.site = site
        self.type = type
        self.official = official
    }

    public var isYouTubeTrailer: Bool {
        site.caseInsensitiveCompare("YouTube") == .orderedSame &&
        (type.caseInsensitiveCompare("Trailer") == .orderedSame || type.caseInsensitiveCompare("Teaser") == .orderedSame)
    }
}

public struct MovieVideoResponse: Codable, Sendable {
    public let id: Int
    public let results: [MovieVideo]

    public init(id: Int, results: [MovieVideo]) {
        self.id = id
        self.results = results
    }
}
