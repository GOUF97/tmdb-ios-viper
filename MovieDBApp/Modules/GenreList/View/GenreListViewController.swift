import UIKit

public final class GenreListViewController: UIViewController {
    public var presenter: GenreListPresenterProtocol!

    private enum Section: Int, CaseIterable {
        case main
    }

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Genre>!
    private let refreshControl = UIRefreshControl()

    private let loadingView = LoadingIndicatorView()
    private let errorView = ErrorStateView()
    private let emptyView = EmptyStateView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupDataSource()
        setupStateViews()
        presenter.viewDidLoad()
    }

    private func setupUI() {
        title = "Movie Genres"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GenreCell.self, forCellWithReuseIdentifier: GenreCell.reuseIdentifier)

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
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(68)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(68)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 24, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Genre>(
            collectionView: collectionView
        ) { collectionView, indexPath, genre in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GenreCell.reuseIdentifier,
                for: indexPath
            ) as? GenreCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: genre)
            return cell
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

// MARK: - GenreListViewProtocol
extension GenreListViewController: GenreListViewProtocol {
    public func showLoading() {
        errorView.isHidden = true
        emptyView.isHidden = true
        if !refreshControl.isRefreshing {
            loadingView.start(message: "Loading genres...")
        }
    }

    public func hideLoading() {
        loadingView.stop()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    public func showGenres(_ genres: [Genre]) {
        loadingView.stop()
        errorView.isHidden = true
        emptyView.isHidden = true
        collectionView.isHidden = false

        var snapshot = NSDiffableDataSourceSnapshot<Section, Genre>()
        snapshot.appendSections([.main])
        snapshot.appendItems(genres, toSection: .main)
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
            title: "No Genres Available",
            message: "Unable to find any movie genres right now.",
            systemImageName: "film"
        )
    }
}

// MARK: - UICollectionViewDelegate
extension GenreListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let genre = dataSource.itemIdentifier(for: indexPath) else { return }
        presenter.didSelectGenre(genre)
    }
}
