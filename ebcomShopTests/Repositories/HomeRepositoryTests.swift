//
//  HomeRepositoryTests.swift
//  ebcomShopTests
//
//  Created by Ibrahim on 2026-02-06.
//

import XCTest
import SwiftData
@testable import ebcomShop

@MainActor
final class HomeRepositoryTests: XCTestCase {
    private var sut: HomeRepository!
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory model container for testing
        let schema = Schema([CachedHomeResponse.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = modelContainer.mainContext
            sut = HomeRepository(modelContext: modelContext)
        } catch {
            fatalError("Failed to create test model container: \(error)")
        }
    }
    
    override func tearDown() {
        sut = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Tests
    
    func testFetchCachedReturnsNilWhenEmpty() {
        // When
        let result = sut.fetchCached()
        
        // Then
        XCTAssertNil(result, "Should return nil when no cached data exists")
    }
    
    func testFetchCachedReturnsDataWhenExists() throws {
        // Given - save some data first
        let response = createMockHomeResponse()
        try sut.save(response)
        
        // When
        let result = sut.fetchCached()
        
        // Then
        XCTAssertNotNil(result, "Should return cached data")
        XCTAssertEqual(result?.shops.count, response.shops.count)
        XCTAssertEqual(result?.categories.count, response.categories.count)
    }
    
    // MARK: - Save Tests
    
    func testSaveStoresDataSuccessfully() throws {
        // Given
        let response = createMockHomeResponse()
        
        // When
        try sut.save(response)
        
        // Then
        let cached = sut.fetchCached()
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.shops.count, 1)
        XCTAssertEqual(cached?.shops.first?.title, "Test Shop")
    }
    
    func testSaveUpdatesExistingData() throws {
        // Given - save initial data
        let initialResponse = createMockHomeResponse()
        try sut.save(initialResponse)
        
        // When - save new data
        let newShop = ShopModel(
            id: "2",
            title: "New Shop",
            iconUrl: "new.png",
            labels: nil,
            tags: nil,
            categories: nil,
            about: nil,
            type: nil,
            code: nil,
            status: nil
        )
        let newResponse = HomeResponse(
            home: initialResponse.home,
            categories: initialResponse.categories,
            shops: [newShop],
            banners: [],
            tags: nil,
            labels: nil
        )
        try sut.save(newResponse)
        
        // Then
        let cached = sut.fetchCached()
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.shops.count, 1)
        XCTAssertEqual(cached?.shops.first?.title, "New Shop")
    }
    
    func testSavePreservesCompleteResponse() throws {
        // Given
        let category = CategoryModel(id: "1", title: "Category", iconUrl: "icon.png", status: nil)
        let shop = ShopModel(
            id: "1",
            title: "Shop",
            iconUrl: "shop.png",
            labels: ["label1"],
            tags: ["tag1"],
            categories: ["cat1"],
            about: ShopAbout(title: "About", description: "Description"),
            type: ["type1"],
            code: "CODE",
            status: "active"
        )
        let banner = BannerModel(id: "1", imageUrl: "banner.jpg")
        let tag = TagModel(id: "tag1", title: "Tag", iconUrl: "tag.png", status: "active")
        
        let sectionPayload = HomeSectionPayload(title: "Section", type: .category, subType: nil, list: ["1"])
        let faq = FAQPayload(id: "faq1", title: "FAQ", sections: [])
        let homePayload = HomePayload(search: true, faq: faq, sections: [sectionPayload])
        
        let response = HomeResponse(
            home: homePayload,
            categories: [category],
            shops: [shop],
            banners: [banner],
            tags: [tag],
            labels: nil
        )
        
        // When
        try sut.save(response)
        
        // Then
        let cached = sut.fetchCached()
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.home.search, true)
        XCTAssertEqual(cached?.categories.count, 1)
        XCTAssertEqual(cached?.shops.count, 1)
        XCTAssertEqual(cached?.banners.count, 1)
        XCTAssertEqual(cached?.tags?.count, 1)
        XCTAssertEqual(cached?.home.faq?.id, "faq1")
    }
    
    func testSaveOnlyStoresSingleCache() throws {
        // Given
        let response1 = createMockHomeResponse()
        let response2 = createMockHomeResponse()
        
        // When
        try sut.save(response1)
        try sut.save(response2)
        
        // Then - verify only one cache entry exists
        let descriptor = FetchDescriptor<CachedHomeResponse>()
        let allCached = try modelContext.fetch(descriptor)
        XCTAssertEqual(allCached.count, 1, "Should only have one cache entry")
    }
    
    // MARK: - Helper Methods
    
    private func createMockHomeResponse() -> HomeResponse {
        let category = CategoryModel(id: "1", title: "Test Category", iconUrl: "icon.png", status: nil)
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
        
        let sectionPayload = HomeSectionPayload(title: "Section", type: .category, subType: nil, list: ["1"])
        let homePayload = HomePayload(search: false, faq: nil, sections: [sectionPayload])
        
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
