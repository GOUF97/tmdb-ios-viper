import UIKit

public actor ImageLoader {
    public static let shared = ImageLoader()

    private let memoryCache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 150 // Keep max 150 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        return cache
    }()

    private let fileManager = FileManager.default
    private let diskCacheDirectory: URL
    private var inFlightTasks: [URL: Task<UIImage, Error>] = [:]

    private init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let diskPath = urls[0].appendingPathComponent("ImageCache", isDirectory: true)
        self.diskCacheDirectory = diskPath

        if !fileManager.fileExists(atPath: diskPath.path) {
            try? fileManager.createDirectory(at: diskPath, withIntermediateDirectories: true)
        }
    }

    public func loadImage(from url: URL) async throws -> UIImage {
        let nsURL = url as NSURL

        // 1. Check in-memory cache
        if let cachedImage = memoryCache.object(forKey: nsURL) {
            return cachedImage
        }

        // 2. Check disk cache
        if let diskImage = loadFromDisk(url: url) {
            let cost = Int(diskImage.size.width * diskImage.size.height * 4)
            memoryCache.setObject(diskImage, forKey: nsURL, cost: cost)
            return diskImage
        }

        // 3. Deduplicate in-flight network requests
        if let existingTask = inFlightTasks[url] {
            return try await existingTask.value
        }

        let downloadTask = Task<UIImage, Error> {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.unknown("Failed to download image from \(url.absoluteString)")
            }

            guard let image = UIImage(data: data) else {
                throw NetworkError.decodingError("Invalid image data.")
            }

            // Save to memory cache
            let cost = data.count
            self.memoryCache.setObject(image, forKey: nsURL, cost: cost)

            // Save to disk asynchronously
            self.saveToDisk(data: data, for: url)

            return image
        }

        inFlightTasks[url] = downloadTask

        do {
            let image = try await downloadTask.value
            inFlightTasks[url] = nil
            return image
        } catch {
            inFlightTasks[url] = nil
            throw error
        }
    }

    private func diskFilePath(for url: URL) -> URL {
        let fileName = url.absoluteString.data(using: .utf8)?.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_") ?? UUID().uuidString
        return diskCacheDirectory.appendingPathComponent(fileName)
    }

    private func loadFromDisk(url: URL) -> UIImage? {
        let filePath = diskFilePath(for: url)
        guard fileManager.fileExists(atPath: filePath.path),
              let data = try? Data(contentsOf: filePath) else {
            return nil
        }
        return UIImage(data: data)
    }

    private func saveToDisk(data: Data, for url: URL) {
        let filePath = diskFilePath(for: url)
        try? data.write(to: filePath, options: .atomic)
    }

    public func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheDirectory)
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }
}

// MARK: - Helper to build TMDb image URLs
public enum TMDbImageSize: String, Sendable {
    case w185
    case w342
    case w500
    case w780
    case original
}

public extension AppEnvironment {
    static func imageURL(path: String?, size: TMDbImageSize = .w500) -> URL? {
        guard let path = path, !path.isEmpty else { return nil }
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let urlString = "https://\(imageBaseURL)/\(size.rawValue)/\(cleanPath)"
        return URL(string: urlString)
    }
}

// MARK: - UIImageView Extension for Asynchronous Loading
private var imageLoadingTaskKey: UInt8 = 0

public extension UIImageView {
    private var currentLoadingTask: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &imageLoadingTaskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &imageLoadingTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    @MainActor
    func setImage(with url: URL?, placeholder: UIImage? = nil) {
        currentLoadingTask?.cancel()
        currentLoadingTask = nil

        image = placeholder

        guard let url = url else { return }

        currentLoadingTask = Task { [weak self] in
            do {
                let downloadedImage = try await ImageLoader.shared.loadImage(from: url)
                guard !Task.isCancelled else { return }
                self?.image = downloadedImage
            } catch {
                guard !Task.isCancelled else { return }
                self?.image = placeholder
            }
        }
    }

    @MainActor
    func cancelImageLoading() {
        currentLoadingTask?.cancel()
        currentLoadingTask = nil
    }
}
