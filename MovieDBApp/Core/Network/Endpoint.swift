import Foundation

public protocol Endpoint: Sendable {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
}

public extension Endpoint {
    var scheme: String { "https" }
    var host: String { AppEnvironment.baseURL }
    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}

public enum TMDbEndpoint: Endpoint {
    case genreList
    case discoverMovies(genreId: Int, page: Int)
    case movieDetail(id: Int)
    case movieReviews(id: Int, page: Int)
    case movieVideos(id: Int)

    public var path: String {
        switch self {
        case .genreList:
            return "/3/genre/movie/list"
        case .discoverMovies:
            return "/3/discover/movie"
        case .movieDetail(let id):
            return "/3/movie/\(id)"
        case .movieReviews(let id, _):
            return "/3/movie/\(id)/reviews"
        case .movieVideos(let id):
            return "/3/movie/\(id)/videos"
        }
    }

    public var method: HTTPMethod {
        .get
    }

    public var queryItems: [URLQueryItem]? {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: AppEnvironment.apiKey),
            URLQueryItem(name: "language", value: "en-US")
        ]

        switch self {
        case .genreList:
            break

        case .discoverMovies(let genreId, let page):
            items.append(URLQueryItem(name: "with_genres", value: String(genreId)))
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "sort_by", value: "popularity.desc"))
            items.append(URLQueryItem(name: "include_adult", value: "false"))

        case .movieDetail:
            break

        case .movieReviews(_, let page):
            items.append(URLQueryItem(name: "page", value: String(page)))

        case .movieVideos:
            break
        }

        return items
    }
}
