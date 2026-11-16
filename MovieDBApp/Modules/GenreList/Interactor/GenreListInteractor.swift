import Foundation

public final class GenreListInteractor: GenreListInteractorInputProtocol {
    public weak var output: GenreListInteractorOutputProtocol?
    private let networkService: NetworkServiceProtocol
    private var cachedGenres: [Genre]?

    public init(networkService: NetworkServiceProtocol = URLSessionNetworkService()) {
        self.networkService = networkService
    }

    public func fetchGenres() {
        if let cached = cachedGenres, !cached.isEmpty {
            output?.didFetchGenres(cached)
            return
        }

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response: GenreResponse = try await self.networkService.request(TMDbEndpoint.genreList)
                self.cachedGenres = response.genres
                self.output?.didFetchGenres(response.genres)
            } catch let error as NetworkError {
                self.output?.didFailToFetchGenres(with: error)
            } catch {
                self.output?.didFailToFetchGenres(with: .unknown(error.localizedDescription))
            }
        }
    }
}
