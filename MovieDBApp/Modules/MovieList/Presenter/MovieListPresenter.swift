import Foundation

public final class MovieListPresenter: MovieListPresenterProtocol {
    public weak var view: MovieListViewProtocol?
    public let interactor: MovieListInteractorInputProtocol
    public let router: MovieListRouterProtocol
    public let genre: Genre

    private var movies: [Movie] = []
    private var totalPages: Int = 1
    private var currentPage: Int = 1
    private var isPaginating: Bool = false

    public init(
        view: MovieListViewProtocol?,
        interactor: MovieListInteractorInputProtocol,
        router: MovieListRouterProtocol,
        genre: Genre
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.genre = genre
    }

    public func viewDidLoad() {
        view?.showLoading()
        interactor.fetchInitialMovies()
    }

    public func didSelectMovie(_ movie: Movie) {
        guard let view = view else { return }
        router.navigateToMovieDetail(for: movie, from: view)
    }

    public func didScrollNearBottom() {
        guard !isPaginating, currentPage < totalPages else { return }
        isPaginating = true
        view?.showFooterLoading()
        interactor.fetchNextPage()
    }

    public func didPullToRefresh() {
        interactor.fetchInitialMovies()
    }

    public func didTapRetry() {
        view?.showLoading()
        interactor.fetchInitialMovies()
    }
}

// MARK: - MovieListInteractorOutputProtocol
extension MovieListPresenter: MovieListInteractorOutputProtocol {
    public func didFetchInitialMovies(_ movies: [Movie], totalPages: Int) {
        self.movies = movies
        self.currentPage = 1
        self.totalPages = totalPages
        self.isPaginating = false

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            self.view?.hideFooterLoading()
            if movies.isEmpty {
                self.view?.showEmptyState()
            } else {
                self.view?.showMovies(movies)
            }
        }
    }

    public func didFetchNextPage(_ newMovies: [Movie], page: Int, totalPages: Int) {
        self.currentPage = page
        self.totalPages = totalPages
        self.movies.append(contentsOf: newMovies)
        self.isPaginating = false

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.view?.hideFooterLoading()
            self.view?.appendMovies(newMovies)
        }
    }

    public func didFailToFetchMovies(with error: NetworkError) {
        self.isPaginating = false
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            self.view?.hideFooterLoading()

            // If we already have movies displayed, only show non-disruptive feedback or retry
            if self.movies.isEmpty {
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
}
