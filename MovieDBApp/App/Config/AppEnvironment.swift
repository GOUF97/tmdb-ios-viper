import Foundation

/// Enterprise configuration manager for securely retrieving API keys and environments
public enum AppEnvironment {
    private enum Keys {
        static let apiKey = "TMDBApiKey"
        static let baseURL = "TMDBBaseURL"
        static let imageBaseURL = "TMDBImageBaseURL"
    }

    /// TMDb API v3 key. Can be populated via Secrets.xcconfig or runtime override.
    public static var apiKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: Keys.apiKey) as? String,
           !key.isEmpty,
           key != "your_tmdb_api_key_here" {
            return key
        }
        // Fallback default or development placeholder
        return _runtimeApiKey ?? ""
    }

    public static var baseURL: String {
        if let host = Bundle.main.object(forInfoDictionaryKey: Keys.baseURL) as? String, !host.isEmpty {
            return host
        }
        return "api.themoviedb.org"
    }

    public static var imageBaseURL: String {
        if let host = Bundle.main.object(forInfoDictionaryKey: Keys.imageBaseURL) as? String, !host.isEmpty {
            return host
        }
        return "image.tmdb.org/t/p"
    }

    // Allows dynamic override during testing or debugging
    private static var _runtimeApiKey: String?

    public static func setRuntimeApiKey(_ key: String) {
        _runtimeApiKey = key
    }
}
