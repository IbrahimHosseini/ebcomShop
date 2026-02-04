# EBCOM Shop Test Suite

This directory contains comprehensive unit tests for all logic functions in the ebcomShop application.

## Test Coverage

### ViewModels
- **HomeViewModelTests.swift**: Tests for `HomeViewModel` including:
  - Initial state verification
  - Successful data loading and mapping
  - Section mapping (categories, banners, shops, fixed banners)
  - Error handling and retry logic
  - Loading state management
  - Handling missing/invalid data

- **SearchViewModelTests.swift**: Tests for `SearchViewModel` including:
  - Initial state and history loading
  - Search functionality (by title and tags)
  - Case-insensitive search
  - Debouncing logic
  - Empty state handling
  - Search history management (add/delete)
  - Tag resolution

### Extensions
- **DictionaryExtensionTests.swift**: Tests for `Dictionary+Extension` including:
  - `trimmedString(forKey:)` - string trimming with whitespace/newlines
  - `string(forKey:)` - raw string extraction
  - `jsonData` - JSON serialization
  - `toJSONString()` - JSON string conversion
  - `asDictionary` - Encodable to dictionary conversion

### Network Layer
- **ResponseHandlerTests.swift**: Tests for `ResponseHandlerImpl` including:
  - Valid JSON decoding (simple, nested, arrays)
  - Optional field handling
  - Invalid JSON error handling
  - Type mismatch error handling
  - Custom decoder support
  - ISO8601 date decoding

- **NetworkClientTests.swift**: Tests for `NetworkClient` including:
  - Successful request execution
  - HTTP status code handling (200, 201, 400, 401, 403, 404, 500)
  - Network error handling
  - Decoding failure handling
  - HTTP method verification

- **NetworkErrorTests.swift**: Tests for `NetworkError` enum including:
  - Error descriptions for all error cases
  - Error codes verification
  - Equality testing
  - LocalizedError conformance

- **APIEndpointTests.swift**: Tests for `APIEndpoint` protocol extension including:
  - URL request creation
  - HTTP method setting
  - Header configuration (default and custom)
  - Base URL and path combination
  - Body serialization for POST/PUT requests
  - Body exclusion for GET requests
  - URL validation and error handling
  - Authentication flag testing

## Test Structure

Each test file follows this structure:
```swift
final class TestClassName: XCTestCase {
    private var sut: ClassUnderTest!  // System Under Test
    private var mockDependency: MockDependency!
    
    override func setUp() {
        // Initialize test dependencies
    }
    
    override func tearDown() {
        // Clean up
    }
    
    // Test methods organized by functionality
}
```

## Mock Objects

The test suite includes the following mock implementations:

- **MockHomeService**: Mock implementation of `HomeServiceProtocol` for testing ViewModels
- **MockSearchHistoryRepository**: Mock implementation for search history persistence
- **MockLocalStorage**: Mock implementation of `LocalStorageProtocol` for testing storage
- **MockAPIHandler**: Mock implementation for network request execution
- **MockResponseHandler**: Mock implementation for response parsing
- **MockEndpoint**: Mock endpoints for network client testing
- **TestEndpoint**: Test endpoint implementation for API endpoint testing

## Running Tests

### In Xcode
1. Open `ebcomShop.xcodeproj` or `ebcomShop.xcworkspace`
2. Select the `ebcomShopTests` scheme
3. Press `Cmd+U` to run all tests
4. Or use `Cmd+Ctrl+Option+U` to run tests with code coverage

### Command Line
```bash
xcodebuild test -scheme ebcomShop -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Naming Convention

Tests follow the naming pattern:
```
test[MethodName][Scenario][ExpectedResult]
```

Examples:
- `testLoadSucceedsWithValidData`
- `testSearchMatchesByTitle`
- `testGetAccessTokenReturnsNilWhenNoToken`

## Code Coverage

To view code coverage:
1. Run tests with code coverage enabled
2. Open the Report Navigator (Cmd+9)
3. Select the test report
4. Click on the Coverage tab

Target coverage: 80%+ for logic classes

