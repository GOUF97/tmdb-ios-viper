import UIKit
import XCTest
@testable import MovieDBApp

@MainActor
final class MockMovieDetailView: MovieDetailViewProtocol {
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var displayedDetail: MovieDetail?
    var displayedTrailerKey: String?
    var displayedReviews: [UserReview]?
    var appendedReviews: [UserReview] = []
    var showEmptyReviewsCalled = false
    var displayedError: String?
    var showReviewFooterLoadingCalled = false
    var hideReviewFooterLoadingCalled = false

    func showLoading() { showLoadingCalled = true }
    func hideLoading() { hideLoadingCalled = true }
    func showMovieDetail(_ detail: MovieDetail, trailerKey: String?) {
        displayedDetail = detail
        displayedTrailerKey = trailerKey
    }
    func showReviews(_ reviews: [UserReview]) { displayedReviews = reviews }
    func appendReviews(_ newReviews: [UserReview]) { appendedReviews.append(contentsOf: newReviews) }
    func showEmptyReviews() { showEmptyReviewsCalled = true }
    func showError(message: String) { displayedError = message }
    func showReviewFooterLoading() { showReviewFooterLoadingCalled = true }
    func hideReviewFooterLoading() { hideReviewFooterLoadingCalled = true }
}

final class MockMovieDetailInteractor: MovieDetailInteractorInputProtocol {
    var fetchMovieDataCalled = false
    var fetchNextReviewPageCalled = false

    func fetchMovieData() { fetchMovieDataCalled = true }
    func fetchNextReviewPage() { fetchNextReviewPageCalled = true }
}

@MainActor
final class MockMovieDetailRouter: MovieDetailRouterProtocol {
    var openedTrailerKey: String?

    func openTrailerModal(trailerKey: String, from view: MovieDetailViewProtocol) {
        openedTrailerKey = trailerKey
    }
}

@MainActor
final class MovieDetailPresenterTests: XCTestCase {
    private var sut: MovieDetailPresenter!
    private var mockView: MockMovieDetailView!
    private var mockInteractor: MockMovieDetailInteractor!
    private var mockRouter: MockMovieDetailRouter!

    override func setUp() {
        super.setUp()
        mockView = MockMovieDetailView()
        mockInteractor = MockMovieDetailInteractor()
        mockRouter = MockMovieDetailRouter()
        sut = MovieDetailPresenter(view: mockView, interactor: mockInteractor, router: mockRouter)
    }

    override func tearDown() {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        super.tearDown()
    }

    func test_viewDidLoad_triggersLoadingAndDataFetch() {
        sut.viewDidLoad()
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockInteractor.fetchMovieDataCalled)
    }

    func test_didFetchMovieData_withReviews_showsDetailAndReviews() async {
        let detail = MovieDetail(id: 1, title: "Avatar", overview: "Pandora adventure")
        let reviews = [UserReview(id: "r1", author: "John Doe", content: "Great movie!")]

        sut.didFetchMovieData(detail: detail, trailerKey: "dQw4w9WgXcQ", reviews: reviews, reviewTotalPages: 2)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertEqual(mockView.displayedDetail?.title, "Avatar")
        XCTAssertEqual(mockView.displayedTrailerKey, "dQw4w9WgXcQ")
        XCTAssertEqual(mockView.displayedReviews, reviews)
    }

    func test_didFetchMovieData_emptyReviews_showsEmptyReviews() async {
        let detail = MovieDetail(id: 1, title: "Avatar")

        sut.didFetchMovieData(detail: detail, trailerKey: nil, reviews: [], reviewTotalPages: 1)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.showEmptyReviewsCalled)
    }

    func test_didFailWithError_showsError() async {
        sut.didFailWithError(.unauthorized)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertEqual(mockView.displayedError, NetworkError.unauthorized.localizedDescription)
    }
}
