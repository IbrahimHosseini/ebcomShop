//
//  SearchViewModelTests.swift
//  ebcomShopTests
//
//  Created by Ibrahim on 2026-02-04.
//

import XCTest
@testable import ebcomShop

@MainActor
final class SearchViewModelTests: XCTestCase {
    private var sut: SearchViewModel!
    private var mockHomeService: MockHomeService!
    private var mockHistoryRepository: MockSearchHistoryRepository!
    private var mockHomeRepository: MockHomeRepository!
    private var mockNetworkMonitor: MockNetworkMonitor!
    
    override func setUp() {
        super.setUp()
        mockHomeService = MockHomeService()
        mockHistoryRepository = MockSearchHistoryRepository()
        mockHomeRepository = MockHomeRepository()
        mockNetworkMonitor = MockNetworkMonitor()
        sut = SearchViewModel(
            homeService: mockHomeService,
            searchHistoryRepository: mockHistoryRepository,
            homeRepository: mockHomeRepository,
            networkMonitor: mockNetworkMonitor
        )
    }
    
    override func tearDown() {
        sut = nil
        mockHomeService = nil
        mockHistoryRepository = nil
        mockHomeRepository = nil
        mockNetworkMonitor = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(sut.query, "", "Initial query should be empty")
        XCTAssertTrue(sut.allShops.isEmpty, "Initial allShops should be empty")
        XCTAssertTrue(sut.results.isEmpty, "Initial results should be empty")
        XCTAssertFalse(sut.isLoading, "Initial isLoading should be false")
        XCTAssertNil(sut.loadError, "Initial loadError should be nil")
        XCTAssertFalse(sut.shouldShowEmptyState, "Initial shouldShowEmptyState should be false")
    }
    
    // MARK: - Load Tests
    
    func testLoadSuccess() async {
        // Given
        let shop1 = ShopModel(
            id: "1",
            title: "Test Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let tag1 = TagModel(id: "tag1", title: "Electronics", iconUrl: nil, status: nil)
        let response = createMockHomeResponse(shops: [shop1], tags: [tag1])
        mockHomeService.result = .success(response)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.loadError)
        XCTAssertEqual(sut.allShops.count, 1)
    }
    
    func testLoadFailure() async {
        // Given
        mockHomeService.result = .failure(.serverError)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.loadError, .serverError)
        XCTAssertTrue(sut.allShops.isEmpty)
    }
    
    func testLoadBuildsTagMapping() async {
        // Given
        let tag1 = TagModel(id: "1", title: "Electronics", iconUrl: nil, status: nil)
        let tag2 = TagModel(id: "2", title: "Fashion", iconUrl: nil, status: nil)
        let shop = ShopModel(
            id: "s1",
            title: "Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: ["1", "2"],
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let response = createMockHomeResponse(shops: [shop], tags: [tag1, tag2])
        mockHomeService.result = .success(response)
        
        // When
        await sut.load()
        
        // Then
        let tagTitles = sut.tagTitles(for: shop)
        XCTAssertEqual(tagTitles.count, 2)
        XCTAssertTrue(tagTitles.contains("Electronics"))
        XCTAssertTrue(tagTitles.contains("Fashion"))
    }
    
    func testLoadPerformsSearchIfQueryIsValid() async {
        // Given
        let shop = ShopModel(
            id: "1",
            title: "Test Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let response = createMockHomeResponse(shops: [shop], tags: nil)
        mockHomeService.result = .success(response)
        sut.query = "Test"
        
        // When
        await sut.load()
        
        // Then
        XCTAssertEqual(sut.results.count, 1)
    }
    
    // MARK: - Query Changed Tests
    
    func testOnQueryChangedWithEmptyQuery() {
        // When
        sut.onQueryChanged("")
        
        // Then
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertFalse(sut.shouldShowEmptyState)
    }
    
    func testOnQueryChangedWithWhitespaceQuery() {
        // When
        sut.onQueryChanged("   ")
        
        // Then
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertFalse(sut.shouldShowEmptyState)
    }
    
    func testOnQueryChangedWithShortQuery() {
        // When
        sut.onQueryChanged("ab")
        
        // Then
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertFalse(sut.shouldShowEmptyState)
    }
    
    func testOnQueryChangedWithValidQueryButNoData() async {
        // Given - no shops loaded yet
        
        // When
        sut.onQueryChanged("test")
        try? await Task.sleep(for: .milliseconds(400))
        
        // Then
        XCTAssertTrue(sut.results.isEmpty)
    }
    
    func testSearchDoesNotSaveHistoryWhenNoMatches() async {
        // Given
        let shop = ShopModel(
            id: "1",
            title: "Test Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let response = createMockHomeResponse(shops: [shop], tags: nil)
        mockHomeService.result = .success(response)
        await sut.load()
        
        // When
        sut.onQueryChanged("nomatch")
        try? await Task.sleep(for: .milliseconds(400))
        
        // Then
        XCTAssertFalse(mockHistoryRepository.addedTerms.contains("nomatch"))
    }
    
    // MARK: - Clear Query Tests
    
    func testClearQuery() {
        // Given
        sut.query = "test"
        
        // When
        sut.clearQuery()
        
        // Then
        XCTAssertEqual(sut.query, "")
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertFalse(sut.shouldShowEmptyState)
    }
    
    // MARK: - Apply History Tests
    
    func testApplyHistory() async {
        // Given
        let shop = ShopModel(
            id: "1",
            title: "Test Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        
        let response = createMockHomeResponse(shops: [shop], tags: nil)
        mockHomeService.result = .success(response)
        await sut.load()
        
        // When
        sut.applyHistory("test")
        try? await Task.sleep(for: .milliseconds(400))
        
        // Then
        XCTAssertEqual(sut.query, "test")
        XCTAssertEqual(sut.results.count, 1)
    }
    
    // MARK: - Delete History Tests
    
    func testDeleteHistory() {
        // Given
        mockHistoryRepository.storedTerms = ["term1", "term2", "term3"]
        
        // When
        sut.deleteHistory(["term1", "term3"])
        
        // Then
        XCTAssertEqual(mockHistoryRepository.deletedTerms.count, 2)
        XCTAssertTrue(mockHistoryRepository.deletedTerms.contains("term1"))
        XCTAssertTrue(mockHistoryRepository.deletedTerms.contains("term3"))
        XCTAssertEqual(sut.history, ["term2"])
    }
    
    // MARK: - Tag Titles Tests
    
    func testTagTitlesReturnsEmptyForNoTags() async {
        // Given
        let shop = ShopModel(
            id: "1",
            title: "Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        
        // When
        let tagTitles = sut.tagTitles(for: shop)
        
        // Then
        XCTAssertTrue(tagTitles.isEmpty)
    }
    
    func testTagTitlesReturnsEmptyForUnknownTags() async {
        // Given
        let shop = ShopModel(
            id: "1",
            title: "Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: ["unknown"],
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        
        // When
        let tagTitles = sut.tagTitles(for: shop)
        
        // Then
        XCTAssertTrue(tagTitles.isEmpty)
    }
    
    func testTagTitlesReturnsKnownTags() async {
        // Given
        let tag1 = TagModel(id: "1", title: "Electronics", iconUrl: nil, status: nil)
        let tag2 = TagModel(id: "2", title: "Fashion", iconUrl: nil, status: nil)
        let shop = ShopModel(
            id: "s1",
            title: "Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: ["1", "2"],
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let response = createMockHomeResponse(shops: [shop], tags: [tag1, tag2])
        mockHomeService.result = .success(response)
        await sut.load()
        
        // When
        let tagTitles = sut.tagTitles(for: shop)
        
        // Then
        XCTAssertEqual(tagTitles.count, 2)
        XCTAssertTrue(tagTitles.contains("Electronics"))
        XCTAssertTrue(tagTitles.contains("Fashion"))
    }
    
    // MARK: - Offline Tests
    
    func testLoadShowsCachedDataImmediately() async {
        // Given - cached data exists
        let shop = ShopModel(
            id: "1",
            title: "Cached Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let cachedResponse = createMockHomeResponse(shops: [shop], tags: nil)
        mockHomeRepository.cachedResponse = cachedResponse
        mockHomeService.result = .success(cachedResponse)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertFalse(sut.allShops.isEmpty, "Should show cached data")
        XCTAssertEqual(sut.allShops.count, 1)
    }
    
    func testLoadOfflineWithCacheShowsData() async {
        // Given - offline with cached data
        let shop = ShopModel(
            id: "1",
            title: "Cached Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let cachedResponse = createMockHomeResponse(shops: [shop], tags: nil)
        mockHomeRepository.cachedResponse = cachedResponse
        mockNetworkMonitor.isConnected = false
        
        // When
        await sut.load()
        
        // Then
        XCTAssertFalse(sut.isLoading, "Should not be loading")
        XCTAssertNil(sut.loadError, "Should not show error with cached data")
        XCTAssertFalse(sut.allShops.isEmpty, "Should show cached data")
        XCTAssertEqual(sut.allShops.count, 1)
    }
    
    func testLoadOfflineWithoutCacheShowsError() async {
        // Given - offline with no cached data
        mockHomeRepository.cachedResponse = nil
        mockNetworkMonitor.isConnected = false
        
        // When
        await sut.load()
        
        // Then
        XCTAssertFalse(sut.isLoading, "Should not be loading")
        XCTAssertEqual(sut.loadError, .noInternetConnection, "Should show no internet error")
        XCTAssertTrue(sut.allShops.isEmpty, "Should have no shops")
    }
    
    func testLoadOfflineSearchWorksOnCachedData() async {
        // Given - offline with cached data and query
        let shop = ShopModel(
            id: "1",
            title: "Test Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let cachedResponse = createMockHomeResponse(shops: [shop], tags: nil)
        mockHomeRepository.cachedResponse = cachedResponse
        mockNetworkMonitor.isConnected = false
        sut.query = "Test"
        
        // When
        await sut.load()
        
        // Then
        XCTAssertFalse(sut.results.isEmpty, "Should show search results from cached data")
        XCTAssertEqual(sut.results.count, 1)
    }
    
    func testLoadNetworkFailureWithCacheShowsData() async {
        // Given - network fails but cache exists
        let shop = ShopModel(
            id: "1",
            title: "Cached Shop",
            iconUrl: "shop.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let cachedResponse = createMockHomeResponse(shops: [shop], tags: nil)
        mockHomeRepository.cachedResponse = cachedResponse
        mockNetworkMonitor.isConnected = true
        mockHomeService.result = .failure(.serverError)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertNil(sut.loadError, "Should not show error when cached data available")
        XCTAssertFalse(sut.allShops.isEmpty, "Should show cached data")
    }
    
    // MARK: - Helper Methods
    
    private func createMockHomeResponse(shops: [ShopModel], tags: [TagModel]?) -> HomeResponse {
        let homePayload = HomePayload(search: false, faq: nil, sections: [])
        return HomeResponse(
            home: homePayload,
            categories: [],
            shops: shops,
            banners: [],
            tags: tags,
            labels: nil
        )
    }
}

// MARK: - Mock Search History Repository

final class MockSearchHistoryRepository: SearchHistoryRepositoryProtocol {
    var storedTerms: [String] = []
    var addedTerms: [String] = []
    var deletedTerms: [String] = []
    
    func fetchTerms() -> [String] {
        return storedTerms
    }
    
    func add(term: String) throws {
        addedTerms.append(term)
        if !storedTerms.contains(term) {
            storedTerms.insert(term, at: 0)
        }
    }
    
    func delete(matching term: String) throws {
        deletedTerms.append(term)
        storedTerms.removeAll { $0.caseInsensitiveCompare(term) == .orderedSame }
    }
}
