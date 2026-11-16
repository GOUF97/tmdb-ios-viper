import UIKit

public final class MovieListRouter: MovieListRouterProtocol {
    public static func createModule(for genre: Genre) -> UIViewController {
        let view = MovieListViewController()
        let interactor = MovieListInteractor(genreId: genre.id)
        let router = MovieListRouter()
        let presenter = MovieListPresenter(
            view: view,
            interactor: interactor,
            router: router,
            genre: genre
        )

        view.presenter = presenter
        view.title = genre.name
        interactor.output = presenter

        return view
    }

    public func navigateToMovieDetail(for movie: Movie, from view: MovieListViewProtocol) {
        guard let sourceViewController = view as? UIViewController else { return }
        let detailVC = MovieDetailRouter.createModule(for: movie.id)
        sourceViewController.navigationController?.pushViewController(detailVC, animated: true)
    }
}
