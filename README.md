# ebcomShop

SwiftUI iOS app for ebcomShop - A modern e-commerce shopping platform.

## 📱 Overview

ebcomShop is a native iOS application built with SwiftUI, featuring a clean architecture with MVVM pattern, comprehensive networking layer, and secure storage management.

## ✨ Features

- 🏠 **Home Screen** - Dynamic sections with categories, banners, fixed banners, and shop listings
- 🔍 **Search** - Real-time search with debouncing and history management
- 🏪 **Shop Browsing** - Browse shops by categories and tags
- 💾 **Offline Support** - Search history persistence with SwiftData
- 🔐 **Secure Storage** - Keychain integration for sensitive data

## 🛠 Technical Stack

- **UI Framework**: SwiftUI
- **Architecture**: MVVM with Observable pattern
- **Networking**: Custom network layer with async/await
- **Storage**: SwiftData for search history; Keychain for auth tokens
- **Concurrency**: Swift Concurrency (async/await, actors)
- **Testing**: XCTest with unit tests

## 📋 Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## 🚀 Getting Started

1. Clone the repository
2. Open `ebcomShop.xcodeproj` in Xcode
3. Select a simulator or device (iOS 17+)
4. Build and run (`Cmd+R`)

## 🏗 Project Structure

```
ebcomShop/
├── App/
│   ├── Home/              # Home screen module
│   │   ├── Models/        # BannerModel, CategoryModel, ShopModel, TagModel, FAQPayload, HomeModels, HomeSectionItem
│   │   ├── Views/         # HomeView, Sections (Banner, Category, Shop, FixedBanner, FAQ)
│   │   ├── ViewModels/    # HomeViewModel
│   │   ├── Services/      # HomeServiceProtocol, HomeServiceImpl
│   │   └── Networking/    # HomeEndpoint
│   ├── Search/            # Search module
│   │   ├── Views/         # SearchView
│   │   └── ViewModels/    # SearchViewModel
│   ├── Components/        # Reusable UI (BannerItemView, CategoryItemView, ShopItemView, SectionHeaderView, ErrorStateView, NavigationHeaderWithSearch, FAQRowView)
│   └── DI/                # EnvironmentKeys (homeService)
├── Network/               # Network layer
│   ├── NetworkClient.swift
│   ├── NetworkClientProtocol.swift
│   ├── APIEndpoint.swift
│   ├── APIHandler.swift
│   ├── ResponseHandler.swift
│   ├── NetworkError.swift
│   ├── NetworkConfiguration.swift
│   ├── HTTPMethod.swift
│   └── AuthSessionManager.swift
├── Storage/               # Storage layer
│   ├── LocalStorageProtocol.swift
│   ├── KeychainStorage.swift
│   ├── UserDefaultsStorage.swift
│   └── AuthStorageManager.swift
├── Repositories/          # SearchHistoryRepository, SearchHistoryRepositoryProtocol
├── Extensions/            # Dictionary+Extension, Font+Extension (TypographyStyle)
├── Logger/                # OSLogger
├── Constants/             # Constants (ResponseResult, NetworkConfigKey)
├── Models/                # SearchHistoryEntry (SwiftData)
└── Resources/            # Assets, Colors, Fonts, Info.plist, LaunchScreen

ebcomShopTests/
├── ViewModels/            # HomeViewModelTests, SearchViewModelTests
├── Network/               # APIEndpointTests, NetworkClientTests, NetworkErrorTests, ResponseHandlerTests
└── Extensions/            # DictionaryExtensionTests
```

## 🧪 Testing

The project includes a unit test suite for ViewModels, Network layer, and Extensions.

### Running Tests

**In Xcode:**
```
Cmd+U                    # Run all tests
Cmd+Ctrl+Option+U        # Run with code coverage
```

**Command Line:**
```bash
xcodebuild test -scheme ebcomShop -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Test Coverage

- ✅ **ViewModels** - HomeViewModel, SearchViewModel
- ✅ **Network Layer** - ResponseHandler, NetworkClient, NetworkError, APIEndpoint
- ✅ **Extensions** - Dictionary (trimmedString, string, jsonData, toJSONString, asDictionary)

For detailed test documentation, see [ebcomShopTests/README.md](ebcomShopTests/README.md)

## 🏛 Architecture

### MVVM Pattern
- **Models**: Data structures and business entities (Decodable/Sendable)
- **Views**: SwiftUI views with declarative UI
- **ViewModels**: Observable classes with @Observable macro

### Network Layer
- Protocol-oriented design (APIEndpoint, APIHandler, ResponseHandler, NetworkClientProtocol)
- Generic NetworkClient with endpoint-based routing
- Automatic request/response handling and error mapping
- AuthSessionManager for token-based auth (optional per endpoint)

### Storage Layer
- LocalStorageProtocol with Keychain and UserDefaults implementations
- StorageFactory for creating storage by type
- AuthStorageManager for token get/clear (Keychain default)

## 🔒 Security

- Keychain storage for sensitive data (tokens)
- AuthSessionManager for session expiry and notifications

## 📦 Dependencies

- **Kingfisher** - Image loading and caching (banners, categories, shops)
- **SwiftUI**, **SwiftData**, **Foundation**, **Security** (Keychain) - built-in

## 🔧 Configuration

Base URL and API configuration:
- `Network/NetworkConfiguration.swift` - reads from Info.plist / .xcconfig
- `Constants/Constants.swift` - NetworkConfigKey (API_BASE_URL, etc.)

## 📝 Code Style

- Swift style guide compliant
- Clear naming conventions
- Modular and testable code
