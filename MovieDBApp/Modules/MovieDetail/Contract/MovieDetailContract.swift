import UIKit

// MARK: - View Protocol
@MainActor
public protocol MovieDetailViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showMovieDetail(_ detail: MovieDetail, trailerKey: String?)
    func showReviews(_ reviews: [UserReview])
    func appendReviews(_ newReviews: [UserReview])
    func showEmptyReviews()
    func showError(message: String)
    func showReviewFooterLoading()
    func hideReviewFooterLoading()
}

// MARK: - Presenter Protocol
@MainActor
public protocol MovieDetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didScrollNearReviewBottom()
    func didTapRetry()
}

// MARK: - Interactor Protocols
public protocol MovieDetailInteractorInputProtocol: AnyObject {
    func fetchMovieData()
    func fetchNextReviewPage()
}

public protocol MovieDetailInteractorOutputProtocol: AnyObject, Sendable {
    func didFetchMovieData(
        detail: MovieDetail,
        trailerKey: String?,
        reviews: [UserReview],
        reviewTotalPages: Int
    )
    func didFetchNextReviewPage(reviews: [UserReview], page: Int, totalPages: Int)
    func didFailWithError(_ error: NetworkError)
}

// MARK: - Router Protocol
@MainActor
public protocol MovieDetailRouterProtocol: AnyObject {
    func openTrailerModal(trailerKey: String, from view: MovieDetailViewProtocol)
}
