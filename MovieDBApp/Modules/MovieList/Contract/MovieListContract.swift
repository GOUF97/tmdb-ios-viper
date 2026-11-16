import UIKit

// MARK: - View Protocol
@MainActor
public protocol MovieListViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showMovies(_ movies: [Movie])
    func appendMovies(_ newMovies: [Movie])
    func showError(message: String)
    func showEmptyState()
    func showFooterLoading()
    func hideFooterLoading()
}

// MARK: - Presenter Protocol
@MainActor
public protocol MovieListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectMovie(_ movie: Movie)
    func didScrollNearBottom()
    func didPullToRefresh()
    func didTapRetry()
}

// MARK: - Interactor Protocols
public protocol MovieListInteractorInputProtocol: AnyObject {
    func fetchInitialMovies()
    func fetchNextPage()
}

public protocol MovieListInteractorOutputProtocol: AnyObject, Sendable {
    func didFetchInitialMovies(_ movies: [Movie], totalPages: Int)
    func didFetchNextPage(_ newMovies: [Movie], page: Int, totalPages: Int)
    func didFailToFetchMovies(with error: NetworkError)
}

// MARK: - Router Protocol
@MainActor
public protocol MovieListRouterProtocol: AnyObject {
    func navigateToMovieDetail(for movie: Movie, from view: MovieListViewProtocol)
}
