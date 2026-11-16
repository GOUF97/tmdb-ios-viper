import Foundation

public final class MovieDetailInteractor: MovieDetailInteractorInputProtocol {
    public weak var output: MovieDetailInteractorOutputProtocol?
    public let movieId: Int
    private let networkService: NetworkServiceProtocol

    private var currentReviewPage: Int = 1
    private var totalReviewPages: Int = 1
    private var isFetchingReviews: Bool = false

    public init(movieId: Int, networkService: NetworkServiceProtocol = URLSessionNetworkService()) {
        self.movieId = movieId
        self.networkService = networkService
    }

    public func fetchMovieData() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                // Execute requests concurrently using structured concurrency
                async let detailTask: MovieDetail = self.networkService.request(TMDbEndpoint.movieDetail(id: self.movieId))
                async let videoTask: MovieVideoResponse = self.networkService.request(TMDbEndpoint.movieVideos(id: self.movieId))
                async let reviewTask: ReviewResponse = self.networkService.request(TMDbEndpoint.movieReviews(id: self.movieId, page: 1))

                let (detail, videos, reviewResponse) = try await (detailTask, videoTask, reviewTask)

                let trailerKey = videos.results.first(where: { $0.isYouTubeTrailer && ($0.official ?? false) })?.key
                    ?? videos.results.first(where: { $0.isYouTubeTrailer })?.key

                self.currentReviewPage = reviewResponse.page
                self.totalReviewPages = reviewResponse.totalPages
                self.isFetchingReviews = false

                self.output?.didFetchMovieData(
                    detail: detail,
                    trailerKey: trailerKey,
                    reviews: reviewResponse.results,
                    reviewTotalPages: reviewResponse.totalPages
                )
            } catch let error as NetworkError {
                self.output?.didFailWithError(error)
            } catch {
                self.output?.didFailWithError(.unknown(error.localizedDescription))
            }
        }
    }

    public func fetchNextReviewPage() {
        guard !isFetchingReviews, currentReviewPage < totalReviewPages else { return }
        isFetchingReviews = true
        let nextPage = currentReviewPage + 1

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let endpoint = TMDbEndpoint.movieReviews(id: self.movieId, page: nextPage)
                let response: ReviewResponse = try await self.networkService.request(endpoint)

                self.currentReviewPage = response.page
                self.totalReviewPages = response.totalPages
                self.isFetchingReviews = false

                self.output?.didFetchNextReviewPage(
                    reviews: response.results,
                    page: response.page,
                    totalPages: response.totalPages
                )
            } catch {
                self.isFetchingReviews = false
                // Non-fatal for review pagination
            }
        }
    }
}
