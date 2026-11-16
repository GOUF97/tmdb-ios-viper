import XCTest
@testable import MovieDBApp

@MainActor
final class GenreListPresenterTests: XCTestCase {
    private var sut: GenreListPresenter!
    private var mockView: MockGenreListView!
    private var mockInteractor: MockGenreListInteractor!
    private var mockRouter: MockGenreListRouter!

    override func setUp() {
        super.setUp()
        mockView = MockGenreListView()
        mockInteractor = MockGenreListInteractor()
        mockRouter = MockGenreListRouter()
        sut = GenreListPresenter(view: mockView, interactor: mockInteractor, router: mockRouter)
    }

    override func tearDown() {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        super.tearDown()
    }

    func test_viewDidLoad_triggersLoadingAndInteractorFetch() {
        sut.viewDidLoad()
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockInteractor.fetchGenresCalled)
    }

    func test_didFetchGenres_whenNotEmpty_displaysGenresOnView() async {
        let genres = [Genre(id: 28, name: "Action"), Genre(id: 35, name: "Comedy")]

        sut.didFetchGenres(genres)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertEqual(mockView.displayedGenres, genres)
    }

    func test_didFetchGenres_whenEmpty_showsEmptyState() async {
        sut.didFetchGenres([])
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.showEmptyStateCalled)
    }

    func test_didFailToFetchGenres_showsErrorMessage() async {
        let networkError = NetworkError.noInternetConnection

        sut.didFailToFetchGenres(with: networkError)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertEqual(mockView.displayedError, networkError.localizedDescription)
    }

    func test_didSelectGenre_routesToMovieList() {
        let genre = Genre(id: 12, name: "Adventure")
        sut.didSelectGenre(genre)
        XCTAssertEqual(mockRouter.navigatedGenre, genre)
    }
}
