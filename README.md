# EBCOM Shop

A SwiftUI iOS e-commerce app for browsing shops, categories, and search with history.

## Overview

ebcomShop is a native iOS app built with SwiftUI: MVVM, a custom async networking layer, and SwiftData for search history.

## Features

- **Home** – Sections for categories, banners, fixed banners, and shop listings
- **Search** – Real-time search with debouncing and persistent history (SwiftData)
- **Shop browsing** – Shops by category and tags; reusable image, tag, and row components
- **Offline Support** – Data cached locally with SwiftData; works without network
- **Storage** – SwiftData for search history and home data caching

## Technical Stack

- **UI**: SwiftUI, reusable components (loading, images, search bar, nav bar, tags, chips)
- **Architecture**: MVVM with `@Observable`, offline-first pattern
- **Networking**: Custom async layer (APIEndpoint, NetworkClient, ResponseHandler, NetworkMonitor)
- **Storage**: SwiftData (search history, home data caching)
- **Testing**: XCTest

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## Getting Started

1. Clone the repository.
2. Open `ebcomShop.xcodeproj` in Xcode.
3. Select a simulator or device (iOS 17+).
4. Build and run (`Cmd+R`).

## Project Structure

```
ebcomShop/
├── App/
│   ├── Components/           # AppProgressView, AppImageView, TagView, SearchBarView,
│   │                        # NavBarToolbar, BannerItemView, CategoryItemView,
│   │                        # ShopItemView, SectionHeaderView, ErrorStateView,
│   │                        # NavigationHeaderWithSearch, FAQRowView
│   ├── DI/                  # EnvironmentKeys (homeService, homeRepository, networkMonitor)
│   ├── Home/
│   │   ├── Models/          # BannerModel, CategoryModel, ShopModel, TagModel,
│   │   │                    # FAQPayload, HomeModels, HomeSectionItem
│   │   │   └── Cache/       # CachedHomeResponse (SwiftData)
│   │   ├── Repositories/    # HomeRepositoryProtocol, HomeRepository
│   │   ├── Views/           # HomeView; Sections: Banner, Category, Shop,
│   │   │                    # FixedBanner, FAQ
│   │   ├── ViewModels/      # HomeViewModel
│   │   ├── Services/        # HomeServiceProtocol, HomeServiceImpl
│   │   └── Networking/      # HomeEndpoint
│   └── Search/
│       ├── Models/          # SearchHistoryEntry (SwiftData)
│       ├── Repositories/    # SearchHistoryRepository, SearchHistoryRepositoryProtocol
│       ├── ViewModels/      # SearchViewModel
│       └── Views/           # SearchView, SearchResultRowView, SearchTextResultView,
│                            # SearchHistorySectionView, HistoryChipView
├── Configs/                 # debug.xcconfig, release.xcconfig
├── Constants/               # Constants (NetworkConfigKey), ResponseResult typealias
├── Extensions/               # Dictionary+Extension, Font+Extension (TypographyStyle)
├── Logger/                  # OSLogger
├── Network/                 # NetworkClient, APIEndpoint, APIHandler, ResponseHandler,
│                            # NetworkConfiguration, NetworkError, HTTPMethod, NetworkMonitor
├── Resources/               # Assets.xcassets, Colors.xcassets, Fonts, Info.plist,
│                            # LaunchScreen.storyboard
└── ebcomShopApp.swift       # App entry, ModelContainer (SwiftData)

ebcomShopTests/
├── ViewModels/              # HomeViewModelTests, SearchViewModelTests
├── Repositories/            # HomeRepositoryTests
├── Network/                 # APIEndpointTests, NetworkClientTests, NetworkErrorTests,
│                            # ResponseHandlerTests, NetworkMonitorTests
└── Extensions/              # DictionaryExtensionTests
```

## Testing

- **ViewModels**: HomeViewModel, SearchViewModel (including offline scenarios)
- **Repositories**: HomeRepository
- **Network**: ResponseHandler, NetworkClient, NetworkError, APIEndpoint, NetworkMonitor
- **Extensions**: Dictionary helpers

Run tests in Xcode with `Cmd+U`, or:

```bash
xcodebuild test -scheme ebcomShop -destination 'platform=iOS Simulator,name=iPhone 16'
```

See [ebcomShopTests/README.md](ebcomShopTests/README.md) for details.

## Architecture

- **MVVM**: Models (Decodable/Sendable), SwiftUI views, ViewModels with `@Observable`
- **Offline-first Pattern**: Data cached locally and synced when network is available
  - Always reads from cache first for instant UI updates
  - Network sync updates cache in background when connected
  - Works fully offline with cached data
- **Network**: Protocol-based (APIEndpoint, NetworkClientProtocol); async/await
  - `NetworkMonitor` for real-time connectivity detection using `NWPathMonitor`
- **Storage**: SwiftData for persistence
  - Search history (SearchHistoryEntry, SearchHistoryRepository)
  - Home data caching (CachedHomeResponse, HomeRepository)
- **Reusable UI**: AppProgressView, AppImageView, TagView, SearchBarView, NavBarToolbar, section/row/chip views

## Dependencies

- **Kingfisher** – image loading and caching
- **SwiftUI**, **SwiftData**, **Foundation** – built-in

## Configuration

- `Network/NetworkConfiguration.swift` – base URL from Info.plist / .xcconfig
- `Constants/Constants.swift` – NetworkConfigKey (e.g. API_BASE_URL)
