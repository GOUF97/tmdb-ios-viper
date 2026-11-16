import UIKit
import SafariServices

public final class MovieDetailRouter: MovieDetailRouterProtocol {
    public static func createModule(for movieId: Int) -> UIViewController {
        let view = MovieDetailViewController()
        let interactor = MovieDetailInteractor(movieId: movieId)
        let router = MovieDetailRouter()
        let presenter = MovieDetailPresenter(
            view: view,
            interactor: interactor,
            router: router
        )

        view.presenter = presenter
        interactor.output = presenter

        return view
    }

    public func openTrailerModal(trailerKey: String, from view: MovieDetailViewProtocol) {
        guard let sourceVC = view as? UIViewController,
              let url = URL(string: "https://www.youtube.com/watch?v=\(trailerKey)") else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        sourceVC.present(safariVC, animated: true)
    }
}
