# EBCOM Shop

A SwiftUI iOS e-commerce app for browsing shops, categories, and search with history.

## Overview

ebcomShop is a native iOS app built with SwiftUI: MVVM, a custom async networking layer, and SwiftData for search history.

## Features

- **Home** – Sections for categories, banners, fixed banners, and shop listings
- **Search** – Real-time search with debouncing and persistent history (SwiftData)
- **Shop browsing** – Shops by category and tags; reusable image, tag, and row components
- **Storage** – SwiftData for search history

## Technical Stack

- **UI**: SwiftUI, reusable components (loading, images, search bar, nav bar, tags, chips)
- **Architecture**: MVVM with `@Observable`
- **Networking**: Custom async layer (APIEndpoint, NetworkClient, ResponseHandler)
- **Storage**: SwiftData (search history)
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
│   ├── DI/                  # EnvironmentKeys (homeService)
│   ├── Home/
│   │   ├── Models/          # BannerModel, CategoryModel, ShopModel, TagModel,
│   │   │                    # FAQPayload, HomeModels, HomeSectionItem
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
│                            # NetworkConfiguration, NetworkError, HTTPMethod
├── Resources/               # Assets.xcassets, Colors.xcassets, Fonts, Info.plist,
│                            # LaunchScreen.storyboard
└── ebcomShopApp.swift       # App entry, ModelContainer (SwiftData)

ebcomShopTests/
├── ViewModels/              # HomeViewModelTests, SearchViewModelTests
├── Network/                 # APIEndpointTests, NetworkClientTests, NetworkErrorTests,
│                            # ResponseHandlerTests
└── Extensions/              # DictionaryExtensionTests
```

## Testing

- **ViewModels**: HomeViewModel, SearchViewModel
- **Network**: ResponseHandler, NetworkClient, NetworkError, APIEndpoint
- **Extensions**: Dictionary helpers

Run tests in Xcode with `Cmd+U`, or:

```bash
xcodebuild test -scheme ebcomShop -destination 'platform=iOS Simulator,name=iPhone 16'
```

See [ebcomShopTests/README.md](ebcomShopTests/README.md) for details.

## Architecture

- **MVVM**: Models (Decodable/Sendable), SwiftUI views, ViewModels with `@Observable`
- **Network**: Protocol-based (APIEndpoint, NetworkClientProtocol); async/await
- **Storage**: SwiftData for search history (SearchHistoryEntry, SearchHistoryRepository)
- **Reusable UI**: AppProgressView, AppImageView, TagView, SearchBarView, NavBarToolbar, section/row/chip views

## Dependencies

- **Kingfisher** – image loading and caching
- **SwiftUI**, **SwiftData**, **Foundation** – built-in

## Configuration

- `Network/NetworkConfiguration.swift` – base URL from Info.plist / .xcconfig
- `Constants/Constants.swift` – NetworkConfigKey (e.g. API_BASE_URL)
