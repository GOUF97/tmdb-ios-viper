import UIKit

// MARK: - View Protocol
@MainActor
public protocol GenreListViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showGenres(_ genres: [Genre])
    func showError(message: String)
    func showEmptyState()
}

// MARK: - Presenter Protocol
@MainActor
public protocol GenreListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectGenre(_ genre: Genre)
    func didPullToRefresh()
    func didTapRetry()
}

// MARK: - Interactor Protocols
public protocol GenreListInteractorInputProtocol: AnyObject {
    func fetchGenres()
}

public protocol GenreListInteractorOutputProtocol: AnyObject, Sendable {
    func didFetchGenres(_ genres: [Genre])
    func didFailToFetchGenres(with error: NetworkError)
}

// MARK: - Router Protocol
@MainActor
public protocol GenreListRouterProtocol: AnyObject {
    func navigateToMovieList(for genre: Genre, from view: GenreListViewProtocol)
}
