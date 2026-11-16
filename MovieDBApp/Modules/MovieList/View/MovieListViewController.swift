import UIKit

public final class MovieListViewController: UIViewController {
    public var presenter: MovieListPresenterProtocol!

    private enum Section: Int, CaseIterable {
        case main
    }

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Movie>!
    private let refreshControl = UIRefreshControl()

    private let loadingView = LoadingIndicatorView()
    private let errorView = ErrorStateView()
    private let emptyView = EmptyStateView()

    private var isFooterLoading: Bool = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupDataSource()
        setupStateViews()
        presenter.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MovieGridCell.self, forCellWithReuseIdentifier: MovieGridCell.reuseIdentifier)
        collectionView.register(
            MovieLoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: MovieLoadingFooterView.reuseIdentifier
        )

        refreshControl.addTarget(self, action: #selector(didPullRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(280)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(280)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(14)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16)

        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        section.boundarySupplementaryItems = [footer]

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Movie>(
            collectionView: collectionView
        ) { collectionView, indexPath, movie in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieGridCell.reuseIdentifier,
                for: indexPath
            ) as? MovieGridCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: movie)
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter,
                  let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MovieLoadingFooterView.reuseIdentifier,
                    for: indexPath
                  ) as? MovieLoadingFooterView else {
                return nil
            }
            if self?.isFooterLoading == true {
                footer.startAnimating()
            } else {
                footer.stopAnimating()
            }
            return footer
        }
    }

    private func setupStateViews() {
        [loadingView, errorView, emptyView].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
            NSLayoutConstraint.activate([
                subview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            subview.isHidden = true
        }

        errorView.onRetryTapped = { [weak self] in
            self?.presenter.didTapRetry()
        }
    }

    @objc private func didPullRefresh() {
        presenter.didPullToRefresh()
    }
}

// MARK: - MovieListViewProtocol
extension MovieListViewController: MovieListViewProtocol {
    public func showLoading() {
        errorView.isHidden = true
        emptyView.isHidden = true
        if !refreshControl.isRefreshing {
            loadingView.start(message: "Discovering movies...")
        }
    }

    public func hideLoading() {
        loadingView.stop()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    public func showMovies(_ movies: [Movie]) {
        loadingView.stop()
        errorView.isHidden = true
        emptyView.isHidden = true
        collectionView.isHidden = false

        var snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movies, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    public func appendMovies(_ newMovies: [Movie]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(newMovies, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    public func showError(message: String) {
        loadingView.stop()
        collectionView.isHidden = true
        emptyView.isHidden = true
        errorView.isHidden = false
        errorView.configure(message: message)
    }

    public func showEmptyState() {
        loadingView.stop()
        collectionView.isHidden = true
        errorView.isHidden = true
        emptyView.isHidden = false
        emptyView.configure(
            title: "No Movies Found",
            message: "There are no movies currently available for this genre.",
            systemImageName: "film"
        )
    }

    public func showFooterLoading() {
        isFooterLoading = true
        collectionView.collectionViewLayout.invalidateLayout()
    }

    public func hideFooterLoading() {
        isFooterLoading = false
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - UICollectionViewDelegate
extension MovieListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
        presenter.didSelectMovie(movie)
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let totalItems = dataSource.snapshot().numberOfItems
        // Trigger endless scrolling when approaching the last 4 items
        if indexPath.item >= totalItems - 4 {
            presenter.didScrollNearBottom()
        }
    }
}
