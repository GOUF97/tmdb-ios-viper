import Foundation

public final class MovieDetailPresenter: MovieDetailPresenterProtocol {
    public weak var view: MovieDetailViewProtocol?
    public let interactor: MovieDetailInteractorInputProtocol
    public let router: MovieDetailRouterProtocol

    private var reviews: [UserReview] = []
    private var currentReviewPage: Int = 1
    private var totalReviewPages: Int = 1
    private var isPaginatingReviews: Bool = false

    public init(
        view: MovieDetailViewProtocol?,
        interactor: MovieDetailInteractorInputProtocol,
        router: MovieDetailRouterProtocol
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    public func viewDidLoad() {
        view?.showLoading()
        interactor.fetchMovieData()
    }

    public func didScrollNearReviewBottom() {
        guard !isPaginatingReviews, currentReviewPage < totalReviewPages else { return }
        isPaginatingReviews = true
        view?.showReviewFooterLoading()
        interactor.fetchNextReviewPage()
    }

    public func didTapRetry() {
        view?.showLoading()
        interactor.fetchMovieData()
    }
}

// MARK: - MovieDetailInteractorOutputProtocol
extension MovieDetailPresenter: MovieDetailInteractorOutputProtocol {
    public func didFetchMovieData(
        detail: MovieDetail,
        trailerKey: String?,
        reviews: [UserReview],
        reviewTotalPages: Int
    ) {
        self.reviews = reviews
        self.currentReviewPage = 1
        self.totalReviewPages = reviewTotalPages
        self.isPaginatingReviews = false

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            self.view?.showMovieDetail(detail, trailerKey: trailerKey)

            if reviews.isEmpty {
                self.view?.showEmptyReviews()
            } else {
                self.view?.showReviews(reviews)
            }
        }
    }

    public func didFetchNextReviewPage(reviews: [UserReview], page: Int, totalPages: Int) {
        self.currentReviewPage = page
        self.totalReviewPages = totalPages
        self.reviews.append(contentsOf: reviews)
        self.isPaginatingReviews = false

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.view?.hideReviewFooterLoading()
            self.view?.appendReviews(reviews)
        }
    }

    public func didFailWithError(_ error: NetworkError) {
        self.isPaginatingReviews = false
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            self.view?.hideReviewFooterLoading()
            self.view?.showError(message: error.localizedDescription)
        }
    }
}
