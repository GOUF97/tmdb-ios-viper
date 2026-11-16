import Foundation

public final class MovieListInteractor: MovieListInteractorInputProtocol {
    public weak var output: MovieListInteractorOutputProtocol?
    private let networkService: NetworkServiceProtocol
    public let genreId: Int

    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var isFetching: Bool = false

    public init(genreId: Int, networkService: NetworkServiceProtocol = URLSessionNetworkService()) {
        self.genreId = genreId
        self.networkService = networkService
    }

    public func fetchInitialMovies() {
        guard !isFetching else { return }
        isFetching = true
        currentPage = 1

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let endpoint = TMDbEndpoint.discoverMovies(genreId: self.genreId, page: 1)
                let response: MovieDiscoverResponse = try await self.networkService.request(endpoint)

                self.currentPage = response.page
                self.totalPages = response.totalPages
                self.isFetching = false

                self.output?.didFetchInitialMovies(response.results, totalPages: response.totalPages)
            } catch let error as NetworkError {
                self.isFetching = false
                self.output?.didFailToFetchMovies(with: error)
            } catch {
                self.isFetching = false
                self.output?.didFailToFetchMovies(with: .unknown(error.localizedDescription))
            }
        }
    }

    public func fetchNextPage() {
        guard !isFetching, currentPage < totalPages else { return }
        isFetching = true
        let nextPage = currentPage + 1

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let endpoint = TMDbEndpoint.discoverMovies(genreId: self.genreId, page: nextPage)
                let response: MovieDiscoverResponse = try await self.networkService.request(endpoint)

                self.currentPage = response.page
                self.totalPages = response.totalPages
                self.isFetching = false

                self.output?.didFetchNextPage(response.results, page: response.page, totalPages: response.totalPages)
            } catch let error as NetworkError {
                self.isFetching = false
                self.output?.didFailToFetchMovies(with: error)
            } catch {
                self.isFetching = false
                self.output?.didFailToFetchMovies(with: .unknown(error.localizedDescription))
            }
        }
    }
}
