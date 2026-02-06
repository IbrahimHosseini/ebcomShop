//
//  HomeViewModelTests.swift
//  ebcomShopTests
//
//  Created by Ibrahim on 2026-02-04.
//

import XCTest
@testable import ebcomShop

@MainActor
final class HomeViewModelTests: XCTestCase {
    private var sut: HomeViewModel!
    private var mockHomeService: MockHomeService!
    private var mockHomeRepository: MockHomeRepository!
    private var mockNetworkMonitor: MockNetworkMonitor!
    
    override func setUp() {
        super.setUp()
        mockHomeService = MockHomeService()
        mockHomeRepository = MockHomeRepository()
        mockNetworkMonitor = MockNetworkMonitor()
        sut = HomeViewModel(
            homeService: mockHomeService,
            homeRepository: mockHomeRepository,
            networkMonitor: mockNetworkMonitor
        )
    }
    
    override func tearDown() {
        sut = nil
        mockHomeService = nil
        mockHomeRepository = nil
        mockNetworkMonitor = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(sut.sections.isEmpty, "Initial sections should be empty")
        XCTAssertNil(sut.faq, "Initial FAQ should be nil")
        XCTAssertFalse(sut.hasSearch, "Initial hasSearch should be false")
        XCTAssertFalse(sut.isLoading, "Initial isLoading should be false")
        XCTAssertNil(sut.loadError, "Initial loadError should be nil")
    }
    
    // MARK: - Successful Load Tests
    
    func testLoadSuccess() async {
        // Given
        let mockResponse = createMockHomeResponse()
        mockHomeService.result = .success(mockResponse)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertFalse(sut.isLoading, "Loading should be false after completion")
        XCTAssertNil(sut.loadError, "Error should be nil on success")
        XCTAssertEqual(sut.sections.count, 2, "Should have 2 sections")
        XCTAssertTrue(sut.hasSearch, "Should have search enabled")
        XCTAssertNotNil(sut.faq, "FAQ should not be nil")
    }
    
    func testLoadMapsCategories() async {
        // Given
        let category1 = CategoryModel(id: "1", title: "Category 1", iconUrl: "icon1.png", status: nil)
        let category2 = CategoryModel(id: "2", title: "Category 2", iconUrl: "icon2.png", status: nil)
        
        let sectionPayload = HomeSectionPayload(
            title: "Categories",
            type: .category,
            subType: nil,
            list: ["1", "2"]
        )
        let homePayload = HomePayload(search: true, faq: nil, sections: [sectionPayload])
        
        let response = HomeResponse(
            home: homePayload,
            categories: [category1, category2],
            shops: [],
            banners: [],
            tags: nil,
            labels: nil
        )
        
        mockHomeService.result = .success(response)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertEqual(sut.sections.count, 1)
        if case .category(let title, let items) = sut.sections[0] {
            XCTAssertEqual(title, "Categories")
            XCTAssertEqual(items.count, 2)
            XCTAssertEqual(items[0].id, "1")
            XCTAssertEqual(items[1].id, "2")
        } else {
            XCTFail("Expected category section")
        }
    }
    
    func testLoadMapsBanners() async {
        // Given
        let banner1 = BannerModel(id: "1", imageUrl: "banner1.jpg")
        let banner2 = BannerModel(id: "2", imageUrl: "banner2.jpg")
        
        let sectionPayload = HomeSectionPayload(
            title: nil,
            type: .banner,
            subType: nil,
            list: ["1", "2"]
        )
        let homePayload = HomePayload(search: false, faq: nil, sections: [sectionPayload])
        
        let response = HomeResponse(
            home: homePayload,
            categories: [],
            shops: [],
            banners: [banner1, banner2],
            tags: nil,
            labels: nil
        )
        
        mockHomeService.result = .success(response)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertEqual(sut.sections.count, 1)
        if case .banner(let items) = sut.sections[0] {
            XCTAssertEqual(items.count, 2)
            XCTAssertEqual(items[0].id, "1")
            XCTAssertEqual(items[1].id, "2")
        } else {
            XCTFail("Expected banner section")
        }
    }
    
    func testLoadMapsShops() async {
        // Given
        let shop1 = ShopModel(
            id: "1",
            title: "Shop 1",
            iconUrl: "shop1.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let shop2 = ShopModel(
            id: "2",
            title: "Shop 2",
            iconUrl: "shop2.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        
        let sectionPayload = HomeSectionPayload(title: "Shops", type: .shop, subType: nil, list: ["1", "2"])
        let homePayload = HomePayload(search: false, faq: nil, sections: [sectionPayload])
        
        let response = HomeResponse(
            home: homePayload,
            categories: [],
            shops: [shop1, shop2],
            banners: [],
            tags: nil,
            labels: nil
        )
        
        mockHomeService.result = .success(response)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertEqual(sut.sections.count, 1)
        if case .shop(let title, let items) = sut.sections[0] {
            XCTAssertEqual(title, "Shops")
            XCTAssertEqual(items.count, 2)
            XCTAssertEqual(items[0].id, "1")
            XCTAssertEqual(items[1].id, "2")
        } else {
            XCTFail("Expected shop section")
        }
    }
    
    func testLoadMapsFixedBanners() async {
        // Given
        let banner1 = BannerModel(id: "1", imageUrl: "banner1.jpg")
        
        let sectionPayload = HomeSectionPayload(title: "Fixed Banner", type: .fixedBanner, subType: nil, list: ["1"])
        let homePayload = HomePayload(search: false, faq: nil, sections: [sectionPayload])
        
        let response = HomeResponse(
            home: homePayload,
            categories: [],
            shops: [],
            banners: [banner1],
            tags: nil,
            labels: nil
        )
        
        mockHomeService.result = .success(response)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertEqual(sut.sections.count, 1)
        if case .fixedBanner(let title, let items) = sut.sections[0] {
            XCTAssertEqual(title, "Fixed Banner")
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items[0].id, "1")
        } else {
            XCTFail("Expected fixed banner section")
        }
    }
    
    func testLoadHandlesMissingItems() async {
        // Given - section references items that don't exist
        let category1 = CategoryModel(id: "1", title: "Category 1", iconUrl: "icon1.png", status: nil)
        
        let sectionPayload = HomeSectionPayload(
            title: "Categories",
            type: .category,
            subType: nil,
            list: ["1", "999"]
        ) // "999" doesn't exist
        let homePayload = HomePayload(search: false, faq: nil, sections: [sectionPayload])
        
        let response = HomeResponse(
            home: homePayload,
            categories: [category1],
            shops: [],
            banners: [],
            tags: nil,
            labels: nil
        )
        
        mockHomeService.result = .success(response)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertEqual(sut.sections.count, 1)
        if case .category(_, let items) = sut.sections[0] {
            XCTAssertEqual(items.count, 1, "Should only include existing items")
            XCTAssertEqual(items[0].id, "1")
        } else {
            XCTFail("Expected category section")
        }
    }
    
    // MARK: - Failed Load Tests
    
    func testLoadFailure() async {
        // Given
        mockHomeService.result = .failure(.serverError)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertFalse(sut.isLoading, "Loading should be false after completion")
        XCTAssertNotNil(sut.loadError, "Error should not be nil on failure")
        XCTAssertEqual(sut.loadError, .serverError)
        XCTAssertTrue(sut.sections.isEmpty, "Sections should be empty on failure")
        XCTAssertNil(sut.faq, "FAQ should be nil on failure")
    }
    
    func testLoadClearsErrorOnRetry() async {
        // Given - first load fails
        mockHomeService.result = .failure(.serverError)
        await sut.load()
        XCTAssertNotNil(sut.loadError)
        
        // When - second load succeeds
        mockHomeService.result = .success(createMockHomeResponse())
        await sut.load()
        
        // Then
        XCTAssertNil(sut.loadError, "Error should be cleared on successful retry")
        XCTAssertFalse(sut.sections.isEmpty, "Sections should be populated")
    }
    
    func testLoadSetsIsLoadingDuringExecution() async {
        // Given
        mockHomeService.delayInSeconds = 0.1
        mockHomeService.result = .success(createMockHomeResponse())
        
        // When
        let task = Task {
            await sut.load()
        }
        
        // Small delay to let load() start
        try? await Task.sleep(for: .milliseconds(50))
        
        // Then
        XCTAssertTrue(sut.isLoading, "Should be loading during execution")
        
        await task.value
        XCTAssertFalse(sut.isLoading, "Should not be loading after completion")
    }
    
    // MARK: - Offline Tests
    
    func testLoadShowsCachedDataImmediately() async {
        // Given - cached data exists
        let cachedResponse = createMockHomeResponse()
        mockHomeRepository.cachedResponse = cachedResponse
        mockHomeService.result = .success(createMockHomeResponse())
        
        // When
        await sut.load()
        
        // Then
        XCTAssertFalse(sut.sections.isEmpty, "Should show cached data")
        XCTAssertEqual(sut.sections.count, 2)
    }
    
    func testLoadUpdatesFromNetworkWhenConnected() async {
        // Given - cached data exists and network is connected
        let cachedResponse = createMockHomeResponse()
        mockHomeRepository.cachedResponse = cachedResponse
        mockNetworkMonitor.isConnected = true
        
        let freshShop = ShopModel(
            id: "2",
            title: "Fresh Shop",
            iconUrl: "fresh.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let freshResponse = HomeResponse(
            home: cachedResponse.home,
            categories: cachedResponse.categories,
            shops: [freshShop],
            banners: [],
            tags: nil,
            labels: nil
        )
        mockHomeService.result = .success(freshResponse)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertTrue(mockHomeRepository.saveCalled, "Should save fresh data")
        XCTAssertNotNil(mockHomeRepository.savedResponse)
    }
    
    func testLoadOfflineWithCacheShowsData() async {
        // Given - offline with cached data
        let cachedResponse = createMockHomeResponse()
        mockHomeRepository.cachedResponse = cachedResponse
        mockNetworkMonitor.isConnected = false
        
        // When
        await sut.load()
        
        // Then
        XCTAssertFalse(sut.isLoading, "Should not be loading")
        XCTAssertNil(sut.loadError, "Should not show error with cached data")
        XCTAssertFalse(sut.sections.isEmpty, "Should show cached data")
        XCTAssertEqual(sut.sections.count, 2)
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
        XCTAssertTrue(sut.sections.isEmpty, "Should have no sections")
    }
    
    func testLoadNetworkFailureWithCacheShowsData() async {
        // Given - network fails but cache exists
        let cachedResponse = createMockHomeResponse()
        mockHomeRepository.cachedResponse = cachedResponse
        mockNetworkMonitor.isConnected = true
        mockHomeService.result = .failure(.serverError)
        
        // When
        await sut.load()
        
        // Then
        XCTAssertNil(sut.loadError, "Should not show error when cached data available")
        XCTAssertFalse(sut.sections.isEmpty, "Should show cached data")
    }
    
    // MARK: - Helper Methods
    
    private func createMockHomeResponse() -> HomeResponse {
        let category = CategoryModel(
            id: "1",
            title: "Test Category",
            iconUrl: "icon.png",
            status: nil
        )
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
        
        let section1 = HomeSectionPayload(title: "Categories", type: .category, subType: nil, list: ["1"])
        let section2 = HomeSectionPayload(title: "Shops", type: .shop, subType: nil, list: ["1"])
        
        let faq = FAQPayload(id: "faq1", title: "FAQ", sections: [])
        let homePayload = HomePayload(search: true, faq: faq, sections: [section1, section2])
        
        return HomeResponse(
            home: homePayload,
            categories: [category],
            shops: [shop],
            banners: [],
            tags: nil,
            labels: nil
        )
    }
}

// MARK: - Mock Home Service

final class MockHomeService: HomeServiceProtocol {
    nonisolated(unsafe) var result: ResponseResult<HomeResponse> = .failure(.noData)
    nonisolated(unsafe) var delayInSeconds: Double = 0
    
    func fetchHome() async -> ResponseResult<HomeResponse> {
        if delayInSeconds > 0 {
            try? await Task.sleep(for: .seconds(delayInSeconds))
        }
        return result
    }
}

// MARK: - Mock Home Repository

@MainActor
final class MockHomeRepository: HomeRepositoryProtocol {
    var cachedResponse: HomeResponse?
    var savedResponse: HomeResponse?
    var saveCalled = false
    var saveError: Error?
    
    nonisolated init() {}
    
    func fetchCached() -> HomeResponse? {
        return cachedResponse
    }
    
    func save(_ response: HomeResponse) throws {
        saveCalled = true
        savedResponse = response
        if let error = saveError {
            throw error
        }
    }
}

// MARK: - Mock Network Monitor

final class MockNetworkMonitor: NetworkMonitor {
    override init() {
        super.init()
    }
    
    convenience init(isConnected: Bool) {
        self.init()
        self.isConnected = isConnected
    }
}
