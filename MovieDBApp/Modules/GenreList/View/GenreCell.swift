import UIKit

public final class GenreCell: UICollectionViewCell {
    public static let reuseIdentifier = "GenreCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.12)
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let chevronImageView: UIImageView = {
        let image = UIImage(systemName: "chevron.right")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 40),
            iconContainerView.heightAnchor.constraint(equalToConstant: 40),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    public func configure(with genre: Genre) {
        titleLabel.text = genre.name
        let symbolName = iconName(for: genre.name)
        iconImageView.image = UIImage(systemName: symbolName)
    }

    private func iconName(for genreName: String) -> String {
        switch genreName.lowercased() {
        case "action": return "flame.fill"
        case "adventure": return "map.fill"
        case "animation": return "sparkles"
        case "comedy": return "face.smiling.fill"
        case "crime": return "shield.lefthalf.filled"
        case "documentary": return "video.fill"
        case "drama": return "theatermasks.fill"
        case "family": return "figure.2.and.child.holdinghands"
        case "fantasy": return "wand.and.stars"
        case "history": return "books.vertical.fill"
        case "horror": return "moon.fill"
        case "music": return "music.note"
        case "mystery": return "magnifyingglass"
        case "romance": return "heart.fill"
        case "science fiction", "sci-fi": return "atom"
        case "tv movie": return "tv.fill"
        case "thriller": return "bolt.fill"
        case "war": return "shield.fill"
        case "western": return "sunset.fill"
        default: return "film.fill"
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.containerView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.backgroundColor = self.isHighlighted
                    ? .tertiarySystemGroupedBackground
                    : .secondarySystemGroupedBackground
            }
        }
    }
}
