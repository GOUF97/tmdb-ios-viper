import UIKit
@testable import MovieDBApp

@MainActor
final class MockGenreListView: GenreListViewProtocol {
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var displayedGenres: [Genre]?
    var displayedError: String?
    var showEmptyStateCalled = false

    func showLoading() { showLoadingCalled = true }
    func hideLoading() { hideLoadingCalled = true }
    func showGenres(_ genres: [Genre]) { displayedGenres = genres }
    func showError(message: String) { displayedError = message }
    func showEmptyState() { showEmptyStateCalled = true }
}

final class MockGenreListInteractor: GenreListInteractorInputProtocol {
    var fetchGenresCalled = false

    func fetchGenres() {
        fetchGenresCalled = true
    }
}

@MainActor
final class MockGenreListRouter: GenreListRouterProtocol {
    var navigatedGenre: Genre?

    func navigateToMovieList(for genre: Genre, from view: GenreListViewProtocol) {
        navigatedGenre = genre
    }
}
