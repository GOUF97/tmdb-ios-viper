import UIKit

public final class MovieGridCell: UICollectionViewCell {
    public static let reuseIdentifier = "MovieGridCell"

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemFill
        imageView.layer.cornerRadius = 12
        imageView.layer.cornerCurve = .continuous
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let ratingBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let ratingIconImageView: UIImageView = {
        let image = UIImage(systemName: "star.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.addSubview(posterImageView)
        posterImageView.addSubview(ratingBadgeView)
        ratingBadgeView.addSubview(ratingIconImageView)
        ratingBadgeView.addSubview(ratingLabel)

        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5),

            ratingBadgeView.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 8),
            ratingBadgeView.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor, constant: 8),
            ratingBadgeView.heightAnchor.constraint(equalToConstant: 22),

            ratingIconImageView.leadingAnchor.constraint(equalTo: ratingBadgeView.leadingAnchor, constant: 6),
            ratingIconImageView.centerYAnchor.constraint(equalTo: ratingBadgeView.centerYAnchor),
            ratingIconImageView.widthAnchor.constraint(equalToConstant: 12),
            ratingIconImageView.heightAnchor.constraint(equalToConstant: 12),

            ratingLabel.leadingAnchor.constraint(equalTo: ratingIconImageView.trailingAnchor, constant: 4),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingBadgeView.trailingAnchor, constant: -6),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingBadgeView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),

            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            yearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            yearLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    public func configure(with movie: Movie) {
        titleLabel.text = movie.title
        yearLabel.text = movie.releaseYear.isEmpty ? "Unknown" : movie.releaseYear
        ratingLabel.text = movie.formattedRating

        let imageURL = AppEnvironment.imageURL(path: movie.posterPath, size: .w500)
        let placeholder = UIImage(systemName: "film")?.withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal)
        posterImageView.setImage(with: imageURL, placeholder: placeholder)
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.cancelImageLoading()
        posterImageView.image = nil
        titleLabel.text = nil
        yearLabel.text = nil
        ratingLabel.text = nil
    }

    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            }
        }
    }
}
