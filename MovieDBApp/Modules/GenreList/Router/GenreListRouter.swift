import UIKit

public final class GenreListRouter: GenreListRouterProtocol {
    public static func createModule() -> UIViewController {
        let view = GenreListViewController()
        let interactor = GenreListInteractor()
        let router = GenreListRouter()
        let presenter = GenreListPresenter(
            view: view,
            interactor: interactor,
            router: router
        )

        view.presenter = presenter
        interactor.output = presenter

        return view
    }

    public func navigateToMovieList(for genre: Genre, from view: GenreListViewProtocol) {
        guard let sourceViewController = view as? UIViewController else { return }
        let movieListVC = MovieListRouter.createModule(for: genre)
        sourceViewController.navigationController?.pushViewController(movieListVC, animated: true)
    }
}
