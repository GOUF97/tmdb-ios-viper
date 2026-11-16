import Foundation

public final class GenreListPresenter: GenreListPresenterProtocol {
    public weak var view: GenreListViewProtocol?
    public let interactor: GenreListInteractorInputProtocol
    public let router: GenreListRouterProtocol

    private var genres: [Genre] = []

    public init(
        view: GenreListViewProtocol?,
        interactor: GenreListInteractorInputProtocol,
        router: GenreListRouterProtocol
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    public func viewDidLoad() {
        view?.showLoading()
        interactor.fetchGenres()
    }

    public func didSelectGenre(_ genre: Genre) {
        guard let view = view else { return }
        router.navigateToMovieList(for: genre, from: view)
    }

    public func didPullToRefresh() {
        interactor.fetchGenres()
    }

    public func didTapRetry() {
        view?.showLoading()
        interactor.fetchGenres()
    }
}

// MARK: - GenreListInteractorOutputProtocol
extension GenreListPresenter: GenreListInteractorOutputProtocol {
    public func didFetchGenres(_ genres: [Genre]) {
        self.genres = genres
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            if genres.isEmpty {
                self.view?.showEmptyState()
            } else {
                self.view?.showGenres(genres)
            }
        }
    }

    public func didFailToFetchGenres(with error: NetworkError) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            self.view?.showError(message: error.localizedDescription)
        }
    }
}
