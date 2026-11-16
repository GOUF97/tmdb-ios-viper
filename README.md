# MovieDBApp (iOS Native - VIPER Architecture)

A high-performance, enterprise-grade native iOS application built with Swift and UIKit demonstrating strict compliance with the **VIPER (View-Interactor-Presenter-Entity-Router)** architectural pattern, modern Swift Concurrency, and zero third-party framework dependencies.

Powered by [The Movie Database (TMDb) API](https://www.themoviedb.org/).

---

## 🏗 Architectural Blueprint: Pure VIPER

The application strictly implements the VIPER architectural pattern with 100% programmatic UIKit (`UICollectionViewCompositionalLayout` and `UICollectionViewDiffableDataSource`):

```
       ┌──────────────────┐
       │       View       │ ◄─── (ViewProtocol, weak)
       └────────┬─────────┘
                │ (User Interactions)
                ▼
       ┌──────────────────┐
 ┌───► │    Presenter     │ ◄─── (PresenterProtocol)
 │     └────────┬─────────┘
 │              │ (Domain & Business Requests)
 │              ▼
 │     ┌──────────────────┐
 └──── │    Interactor    │ ───► Entities / Network Layer
       └──────────────────┘
                │ (Navigation Routing)
                ▼
       ┌──────────────────┐
       │      Router      │ ◄─── (Wireframe & Dependency Assembly)
       └──────────────────┘
```

### Memory Management & Concurrency Hygiene:
* **ARC Retain Cycle Prevention:**
  * `Presenter` holds a `weak var view: ViewProtocol?`
  * `Interactor` holds a `weak var output: InteractorOutputProtocol?`
  * `Router` uses weak view controller anchors
* **Strict Swift Concurrency:**
  * Network operations leverage structured concurrency (`async`/`await`, `async let` for parallel execution)
  * Two-tier image caching implemented with a thread-safe Swift `actor` (`ImageLoader`)
  * UI state rendering strictly routed via `@MainActor`

---

## 🎯 User Stories & Feature Checklist

| # | User Story | Status | Implementation Details |
|---|------------|:------:|------------------------|
| 1 | **Movie Genre List** | ✅ Complete | Dynamic list with category icons, subtle feedback animations, and caching. |
| 2 | **Discover Movies by Genre** | ✅ Complete | Responsive 2-column grid displaying poster, rating, and release year. |
| 3 | **Movie Primary Information** | ✅ Complete | Backdrop poster, runtime, genres, rating, tagline, and full overview. |
| 4 | **User Reviews** | ✅ Complete | Author details, rating badge, timestamp, and review content. |
| 5 | **YouTube Trailer** | ✅ Complete | Inline `WKWebView` HTML5 YouTube player embedded seamlessly into detail header. |
| 6 | **Endless Scrolling** | ✅ Complete | Debounced pagination state machine on movie grid and user reviews. |
| 7 | **Positive & Negative Cases** | ✅ Complete | Dedicated Error State with Retry, Empty States, and Loading Shimmer indicators. |

---

## 🛡️ Enterprise Security & Configuration

API keys and sensitive endpoints are isolated from code:

1. Copy the configuration template:
   ```bash
   cp MovieDBApp/App/Config/Secrets.xcconfig.example MovieDBApp/App/Config/Secrets.xcconfig
   ```
2. Open `MovieDBApp/App/Config/Secrets.xcconfig` and insert your TMDb API Key (v3 auth):
   ```xcconfig
   TMDB_API_KEY = your_actual_tmdb_api_key_here
   TMDB_BASE_URL = api.themoviedb.org
   TMDB_IMAGE_BASE_URL = image.tmdb.org/t/p
   ```
3. `Secrets.xcconfig` is already ignored by `.gitignore` to prevent leaking credentials in public repositories.

---

## 🧪 Unit Testing

Unit tests cover the core VIPER components (**Presenter** and **Interactor**), verifying deterministic state transitions:

* `GenreListPresenterTests`: Tests loading state, non-empty genre list rendering, empty state fallback, error routing, and module navigation.
* `MovieListPresenterTests`: Tests initial page fetch, pagination triggering, boundary conditions, and detail routing.
* `MovieDetailPresenterTests`: Tests concurrent data aggregation, trailer key resolution, and review pagination.

### Run Tests in Xcode:
Press `Cmd + U` or run via command line:
```bash
xcodebuild -project MovieDBApp.xcodeproj -scheme MovieDBApp -destination 'platform=iOS Simulator,name=iPhone 16' test
```

---

## 📱 Requirements & Compatibility
* **iOS Target:** iOS 16.0+
* **Language:** Swift 5.9+ / Swift 6
* **IDE:** Xcode 15 / Xcode 16 / Xcode 27+
* **Dependencies:** None (Pure native frameworks: `UIKit`, `WebKit`, `SafariServices`)
