import UIKit
import XCTest
@testable import MovieDBApp

@MainActor
final class MockMovieListView: MovieListViewProtocol {
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var displayedMovies: [Movie]?
    var appendedMovies: [Movie] = []
    var displayedError: String?
    var showEmptyStateCalled = false
    var showFooterLoadingCalled = false
    var hideFooterLoadingCalled = false

    func showLoading() { showLoadingCalled = true }
    func hideLoading() { hideLoadingCalled = true }
    func showMovies(_ movies: [Movie]) { displayedMovies = movies }
    func appendMovies(_ newMovies: [Movie]) { appendedMovies.append(contentsOf: newMovies) }
    func showError(message: String) { displayedError = message }
    func showEmptyState() { showEmptyStateCalled = true }
    func showFooterLoading() { showFooterLoadingCalled = true }
    func hideFooterLoading() { hideFooterLoadingCalled = true }
}

final class MockMovieListInteractor: MovieListInteractorInputProtocol {
    var fetchInitialMoviesCalled = false
    var fetchNextPageCalled = false

    func fetchInitialMovies() { fetchInitialMoviesCalled = true }
    func fetchNextPage() { fetchNextPageCalled = true }
}

@MainActor
final class MockMovieListRouter: MovieListRouterProtocol {
    var navigatedMovie: Movie?

    func navigateToMovieDetail(for movie: Movie, from view: MovieListViewProtocol) {
        navigatedMovie = movie
    }
}

@MainActor
final class MovieListPresenterTests: XCTestCase {
    private var sut: MovieListPresenter!
    private var mockView: MockMovieListView!
    private var mockInteractor: MockMovieListInteractor!
    private var mockRouter: MockMovieListRouter!
    private let sampleGenre = Genre(id: 28, name: "Action")

    override func setUp() {
        super.setUp()
        mockView = MockMovieListView()
        mockInteractor = MockMovieListInteractor()
        mockRouter = MockMovieListRouter()
        sut = MovieListPresenter(view: mockView, interactor: mockInteractor, router: mockRouter, genre: sampleGenre)
    }

    override func tearDown() {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        super.tearDown()
    }

    func test_viewDidLoad_triggersLoadingAndInitialFetch() {
        sut.viewDidLoad()
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockInteractor.fetchInitialMoviesCalled)
    }

    func test_didFetchInitialMovies_whenNotEmpty_showsMovies() async {
        let movies = [
            Movie(id: 1, title: "Inception"),
            Movie(id: 2, title: "Interstellar")
        ]

        sut.didFetchInitialMovies(movies, totalPages: 5)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertEqual(mockView.displayedMovies, movies)
    }

    func test_didFetchInitialMovies_whenEmpty_showsEmptyState() async {
        sut.didFetchInitialMovies([], totalPages: 1)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.showEmptyStateCalled)
    }

    func test_didScrollNearBottom_whenMorePagesAvailable_triggersNextPage() {
        sut.didFetchInitialMovies([Movie(id: 1, title: "Movie 1")], totalPages: 3)
        sut.didScrollNearBottom()

        XCTAssertTrue(mockInteractor.fetchNextPageCalled)
        XCTAssertTrue(mockView.showFooterLoadingCalled)
    }

    func test_didSelectMovie_navigatesToDetail() {
        let movie = Movie(id: 100, title: "Dune")
        sut.didSelectMovie(movie)
        XCTAssertEqual(mockRouter.navigatedMovie, movie)
    }
}
