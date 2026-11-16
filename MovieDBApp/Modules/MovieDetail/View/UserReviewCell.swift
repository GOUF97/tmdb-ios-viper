import UIKit

public final class UserReviewCell: UICollectionViewCell {
    public static let reuseIdentifier = "UserReviewCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 6
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
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(authorLabel)
        containerView.addSubview(ratingLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(contentLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            avatarImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 36),
            avatarImageView.heightAnchor.constraint(equalToConstant: 36),

            authorLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            authorLabel.trailingAnchor.constraint(lessThanOrEqualTo: ratingLabel.leadingAnchor, constant: -8),

            dateLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),

            ratingLabel.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            contentLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            contentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    public func configure(with review: UserReview) {
        authorLabel.text = review.author
        contentLabel.text = review.content

        if let rating = review.authorDetails?.rating, rating > 0 {
            ratingLabel.text = "★ \(Int(rating))/10"
            ratingLabel.isHidden = false
        } else {
            ratingLabel.isHidden = true
        }

        if let dateString = review.createdAt, dateString.count >= 10 {
            dateLabel.text = String(dateString.prefix(10))
        } else {
            dateLabel.text = nil
        }

        let placeholder = UIImage(systemName: "person.circle.fill")
        if let avatarPath = review.authorDetails?.avatarPath {
            let cleanAvatarPath: String
            if avatarPath.hasPrefix("/https:") || avatarPath.hasPrefix("/http:") {
                cleanAvatarPath = String(avatarPath.dropFirst())
                avatarImageView.setImage(with: URL(string: cleanAvatarPath), placeholder: placeholder)
            } else {
                let url = AppEnvironment.imageURL(path: avatarPath, size: .w185)
                avatarImageView.setImage(with: url, placeholder: placeholder)
            }
        } else {
            avatarImageView.image = placeholder
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.cancelImageLoading()
        avatarImageView.image = nil
        authorLabel.text = nil
        contentLabel.text = nil
        ratingLabel.text = nil
        dateLabel.text = nil
    }
}
