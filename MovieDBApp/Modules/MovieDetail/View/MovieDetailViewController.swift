import UIKit

public final class MovieDetailViewController: UIViewController {
    public var presenter: MovieDetailPresenterProtocol!

    private enum Section: Int, CaseIterable {
        case reviews
    }

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, UserReview>!

    private let loadingView = LoadingIndicatorView()
    private let errorView = ErrorStateView()

    private var movieDetail: MovieDetail?
    private var trailerKey: String?
    private var hasReviews: Bool = true
    private var isReviewFooterLoading: Bool = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupDataSource()
        setupStateViews()
        presenter.viewDidLoad()
    }

    private func setupUI() {
        title = "Movie Details"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(UserReviewCell.self, forCellWithReuseIdentifier: UserReviewCell.reuseIdentifier)
        collectionView.register(
            MovieDetailHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MovieDetailHeaderView.reuseIdentifier
        )
        collectionView.register(
            MovieLoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: MovieLoadingFooterView.reuseIdentifier
        )

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
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 0)

        // Header for Backdrop, Trailer, and Movie Metadata
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(450)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        // Footer for Reviews Endless Scrolling
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )

        section.boundarySupplementaryItems = [header, footer]

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, UserReview>(
            collectionView: collectionView
        ) { collectionView, indexPath, review in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserReviewCell.reuseIdentifier,
                for: indexPath
            ) as? UserReviewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: review)
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }

            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MovieDetailHeaderView.reuseIdentifier,
                    for: indexPath
                ) as? MovieDetailHeaderView else {
                    return nil
                }
                if let detail = self.movieDetail {
                    header.configure(with: detail, trailerKey: self.trailerKey)
                }
                return header
            } else if kind == UICollectionView.elementKindSectionFooter {
                guard let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MovieLoadingFooterView.reuseIdentifier,
                    for: indexPath
                ) as? MovieLoadingFooterView else {
                    return nil
                }
                if self.isReviewFooterLoading {
                    footer.startAnimating()
                } else {
                    footer.stopAnimating()
                }
                return footer
            }
            return nil
        }
    }

    private func setupStateViews() {
        [loadingView, errorView].forEach { subview in
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
}

// MARK: - MovieDetailViewProtocol
extension MovieDetailViewController: MovieDetailViewProtocol {
    public func showLoading() {
        errorView.isHidden = true
        loadingView.start(message: "Loading details...")
        collectionView.isHidden = true
    }

    public func hideLoading() {
        loadingView.stop()
        collectionView.isHidden = false
    }

    public func showMovieDetail(_ detail: MovieDetail, trailerKey: String?) {
        self.movieDetail = detail
        self.trailerKey = trailerKey
        title = detail.title

        var snapshot = dataSource.snapshot()
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections([.reviews])
            dataSource.apply(snapshot, animatingDifferences: false)
        } else {
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    public func showReviews(_ reviews: [UserReview]) {
        self.hasReviews = true
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserReview>()
        snapshot.appendSections([.reviews])
        snapshot.appendItems(reviews, toSection: .reviews)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    public func appendReviews(_ newReviews: [UserReview]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(newReviews, toSection: .reviews)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    public func showEmptyReviews() {
        self.hasReviews = false
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserReview>()
        snapshot.appendSections([.reviews])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    public func showError(message: String) {
        loadingView.stop()
        collectionView.isHidden = true
        errorView.isHidden = false
        errorView.configure(message: message)
    }

    public func showReviewFooterLoading() {
        isReviewFooterLoading = true
        collectionView.collectionViewLayout.invalidateLayout()
    }

    public func hideReviewFooterLoading() {
        isReviewFooterLoading = false
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - UICollectionViewDelegate
extension MovieDetailViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let totalItems = dataSource.snapshot().numberOfItems
        if totalItems > 0 && indexPath.item >= totalItems - 2 {
            presenter.didScrollNearReviewBottom()
        }
    }
}
