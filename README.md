# ebcomShop

SwiftUI iOS app for ebcomShop - A modern e-commerce shopping platform.

## 📱 Overview

ebcomShop is a native iOS application built with SwiftUI, featuring a clean architecture with MVVM pattern, comprehensive networking layer, and secure storage management.

## ✨ Features

- 🏠 **Home Screen** - Dynamic sections with categories, banners, and shop listings
- 🔍 **Search** - Real-time search with debouncing and history management
- 🏪 **Shop Browsing** - Browse shops by categories and tags
- 💾 **Offline Support** - Search history persistence with SwiftData
- 🔐 **Secure Storage** - Keychain integration for sensitive data

## 🛠 Technical Stack

- **UI Framework**: SwiftUI
- **Architecture**: MVVM with Observable pattern
- **Networking**: Custom network layer with async/await
- **Storage**: SwiftData for local persistence, Keychain for secure storage
- **Concurrency**: Swift Concurrency (async/await, actors)
- **Testing**: XCTest with comprehensive unit tests

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
│   │   ├── Models/        # Data models
│   │   ├── Views/         # SwiftUI views
│   │   ├── ViewModels/    # Business logic
│   │   ├── Services/      # Service protocols
│   │   └── Networking/    # API endpoints
│   ├── Search/            # Search module
│   │   ├── Views/         # Search UI
│   │   └── ViewModels/    # Search logic
│   ├── Components/        # Reusable UI components
│   └── DI/                # Dependency injection
├── Network/               # Network layer
│   ├── NetworkClient.swift
│   ├── APIEndpoint.swift
│   ├── ResponseHandler.swift
│   └── NetworkError.swift
├── Storage/               # Storage layer
│   ├── KeychainStorage.swift
│   ├── UserDefaultsStorage.swift
│   └── AuthStorageManager.swift
├── Repositories/          # Data repositories
├── Extensions/            # Swift extensions
├── Models/                # Shared models
└── Resources/             # Assets and configuration

ebcomShopTests/            # Unit tests (154 tests)
├── ViewModels/            # ViewModel tests
├── Network/               # Network layer tests
├── Storage/               # Storage layer tests
└── Extensions/            # Extension tests
```

## 🧪 Testing

The project includes a comprehensive test suite with **154 unit tests** covering all logic functions.

### Running Tests

**In Xcode:**
```
Cmd+U                    # Run all tests
Cmd+Ctrl+Option+U        # Run with code coverage
```

**Command Line:**
```bash
xcodebuild test -scheme ebcomShop -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Coverage

- ✅ **ViewModels** - 38 tests
  - HomeViewModel (15 tests)
  - SearchViewModel (23 tests)
- ✅ **Network Layer** - 66 tests
  - ResponseHandler (12 tests)
  - NetworkClient (12 tests)
  - NetworkError (28 tests)
  - APIEndpoint (14 tests)
- ✅ **Storage** - 14 tests
  - AuthStorageManager (14 tests)
- ✅ **Extensions** - 22 tests
  - Dictionary extensions (22 tests)

**Total Code Coverage**: 80%+ for logic classes

For detailed test documentation, see [ebcomShopTests/README.md](ebcomShopTests/README.md)

## 🏛 Architecture

### MVVM Pattern
- **Models**: Data structures and business entities
- **Views**: SwiftUI views with declarative UI
- **ViewModels**: Observable classes with @Observable macro

### Network Layer
- Protocol-oriented design
- Generic NetworkClient with endpoint-based routing
- Automatic request/response handling
- Built-in error mapping and retry logic

### Storage Layer
- Multiple storage backends (Keychain, UserDefaults)
- Factory pattern for storage creation
- Secure token management

## 🔒 Security

- Keychain storage for sensitive data (tokens, credentials)
- Secure session management
- Automatic token refresh handling
- Session expiry notifications

## 📦 Dependencies

This project uses **zero external dependencies** - all networking, storage, and business logic is implemented natively using:
- Foundation
- SwiftUI
- SwiftData
- Security (Keychain)

## 🔧 Configuration

Base URL and API configuration can be modified in:
- `Network/NetworkConfiguration.swift`
- `Constants/Constants.swift`

## 📝 Code Style

- Swift style guide compliant
- Clear naming conventions
- Comprehensive documentation comments
- Modular and testable code
