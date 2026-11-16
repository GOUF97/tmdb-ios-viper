import UIKit
import WebKit

public final class MovieDetailHeaderView: UICollectionReusableView {
    public static let reuseIdentifier = "MovieDetailHeaderView"

    public var onTrailerPlayRequested: (() -> Void)?

    private let backdropContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isHidden = true
        return webView
    }()

    private let playTrailerButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Watch Trailer"
        config.image = UIImage(systemName: "play.fill")
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemBlue
        label.numberOfLines = 0
        return label
    }()

    private let overviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Overview"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let reviewsHeaderTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "User Reviews"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
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
        addSubview(backdropContainerView)
        backdropContainerView.addSubview(backdropImageView)
        backdropContainerView.addSubview(webView)
        backdropContainerView.addSubview(playTrailerButton)

        addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(taglineLabel)
        contentStackView.addArrangedSubview(metadataLabel)
        contentStackView.addArrangedSubview(genresLabel)
        contentStackView.addArrangedSubview(overviewTitleLabel)
        contentStackView.addArrangedSubview(overviewLabel)
        contentStackView.addArrangedSubview(reviewsHeaderTitleLabel)

        playTrailerButton.addTarget(self, action: #selector(didTapPlayTrailer), for: .touchUpInside)

        NSLayoutConstraint.activate([
            backdropContainerView.topAnchor.constraint(equalTo: topAnchor),
            backdropContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdropContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdropContainerView.heightAnchor.constraint(equalTo: backdropContainerView.widthAnchor, multiplier: 9.0 / 16.0),

            backdropImageView.topAnchor.constraint(equalTo: backdropContainerView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: backdropContainerView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: backdropContainerView.trailingAnchor),
            backdropImageView.bottomAnchor.constraint(equalTo: backdropContainerView.bottomAnchor),

            webView.topAnchor.constraint(equalTo: backdropContainerView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: backdropContainerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: backdropContainerView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: backdropContainerView.bottomAnchor),

            playTrailerButton.centerXAnchor.constraint(equalTo: backdropContainerView.centerXAnchor),
            playTrailerButton.centerYAnchor.constraint(equalTo: backdropContainerView.centerYAnchor),

            contentStackView.topAnchor.constraint(equalTo: backdropContainerView.bottomAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    public func configure(with detail: MovieDetail, trailerKey: String?) {
        titleLabel.text = detail.title

        if let tagline = detail.tagline, !tagline.isEmpty {
            taglineLabel.text = "\"\(tagline)\""
            taglineLabel.isHidden = false
        } else {
            taglineLabel.isHidden = true
        }

        var metaComponents: [String] = []
        if !detail.releaseYear.isEmpty {
            metaComponents.append(detail.releaseYear)
        }
        if !detail.formattedRuntime.isEmpty {
            metaComponents.append(detail.formattedRuntime)
        }
        if detail.formattedRating != "N/A" {
            metaComponents.append("⭐ \(detail.formattedRating)/10")
        }
        metadataLabel.text = metaComponents.joined(separator: "  •  ")

        let genres = detail.genreNames
        genresLabel.text = genres
        genresLabel.isHidden = genres.isEmpty

        overviewLabel.text = detail.overview ?? "No overview available."

        // Configure backdrop & trailer
        let backdropURL = AppEnvironment.imageURL(path: detail.backdropPath ?? detail.posterPath, size: .w780)
        backdropImageView.setImage(with: backdropURL)

        if let key = trailerKey, !key.isEmpty {
            playTrailerButton.isHidden = false
            loadYouTubeTrailer(key: key)
        } else {
            playTrailerButton.isHidden = true
            webView.isHidden = true
            backdropImageView.isHidden = false
        }
    }

    private func loadYouTubeTrailer(key: String) {
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body { margin: 0; padding: 0; background-color: #000; overflow: hidden; }
                iframe { width: 100vw; height: 100vh; border: none; }
            </style>
        </head>
        <body>
            <iframe
                src="https://www.youtube.com/embed/\(key)?playsinline=1&rel=0&modestbranding=1"
                frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen>
            </iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(embedHTML, baseURL: URL(string: "https://www.youtube.com"))
    }

    @objc private func didTapPlayTrailer() {
        playTrailerButton.isHidden = true
        backdropImageView.isHidden = true
        webView.isHidden = false
        onTrailerPlayRequested?()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        backdropImageView.cancelImageLoading()
        backdropImageView.image = nil
        webView.stopLoading()
        webView.isHidden = true
        backdropImageView.isHidden = false
        playTrailerButton.isHidden = true
    }
}
