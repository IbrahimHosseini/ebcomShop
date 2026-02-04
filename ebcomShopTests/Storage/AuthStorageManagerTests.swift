//
//  AuthStorageManagerTests.swift
//  ebcomShopTests
//
//  Created by Ibrahim on 2026-02-04.
//

import XCTest
@testable import ebcomShop

final class AuthStorageManagerTests: XCTestCase {
    private var sut: AuthStorageManager!
    private var mockStorage: MockLocalStorage!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockLocalStorage()
        sut = AuthStorageManager(storage: mockStorage)
    }
    
    override func tearDown() {
        sut = nil
        mockStorage = nil
        super.tearDown()
    }
    
    // MARK: - Store Tokens Tests
    
    func testStoreTokens() {
        // When
        sut.storeTokens(accessToken: "access123", refreshToken: "refresh456")
        
        // Then
        XCTAssertEqual(mockStorage.storedValues["ebcom.accessToken"] as? String, "access123")
    }
    
    func testStoreTokensWithExpiry() {
        // When
        sut.storeTokens(accessToken: "access123", refreshToken: "refresh456", expiresIn: 3600)
        
        // Then
        XCTAssertEqual(mockStorage.storedValues["ebcom.accessToken"] as? String, "access123")
    }
    
    func testStoreTokensOverwritesExisting() {
        // Given
        sut.storeTokens(accessToken: "old_token", refreshToken: "old_refresh")
        
        // When
        sut.storeTokens(accessToken: "new_token", refreshToken: "new_refresh")
        
        // Then
        XCTAssertEqual(mockStorage.storedValues["ebcom.accessToken"] as? String, "new_token")
    }
    
    // MARK: - Get Access Token Tests
    
    func testGetAccessTokenReturnsStoredToken() {
        // Given
        sut.storeTokens(accessToken: "access123", refreshToken: "refresh456")
        
        // When
        let token = sut.getAccessToken()
        
        // Then
        XCTAssertEqual(token, "access123")
    }
    
    func testGetAccessTokenReturnsNilWhenNoToken() {
        // When
        let token = sut.getAccessToken()
        
        // Then
        XCTAssertNil(token)
    }
    
    // MARK: - Has Valid Tokens Tests
    
    func testHasValidTokensReturnsTrueWhenTokensExist() {
        // Given
        sut.storeTokens(accessToken: "access123", refreshToken: "refresh456")
        
        // When
        let hasTokens = sut.hasValidTokens()
        
        // Then
        XCTAssertTrue(hasTokens)
    }
    
    func testHasValidTokensReturnsFalseWhenNoTokens() {
        // When
        let hasTokens = sut.hasValidTokens()
        
        // Then
        XCTAssertFalse(hasTokens)
    }
    
    // MARK: - Is Authenticated Tests
    
    func testIsAuthenticatedReturnsTrueWhenTokensExist() {
        // Given
        sut.storeTokens(accessToken: "access123", refreshToken: "refresh456")
        
        // When
        let isAuthenticated = sut.isAuthenticated()
        
        // Then
        XCTAssertTrue(isAuthenticated)
    }
    
    func testIsAuthenticatedReturnsFalseWhenNoTokens() {
        // When
        let isAuthenticated = sut.isAuthenticated()
        
        // Then
        XCTAssertFalse(isAuthenticated)
    }
    
    // MARK: - Clear Session Tests
    
    func testClearSessionRemovesTokens() {
        // Given
        sut.storeTokens(accessToken: "access123", refreshToken: "refresh456")
        XCTAssertTrue(sut.hasValidTokens())
        
        // When
        sut.clearSession()
        
        // Then
        XCTAssertFalse(sut.hasValidTokens())
        XCTAssertNil(mockStorage.storedValues["ebcom.accessToken"])
    }
    
    func testClearSessionWhenNoTokens() {
        // When
        sut.clearSession()
        
        // Then
        XCTAssertFalse(sut.hasValidTokens())
    }
    
    // MARK: - Storage Type Tests
    
    func testDefaultStorageTypeIsKeychain() {
        // Given
        let manager = AuthStorageManager()
        
        // Then
        XCTAssertEqual(manager.storageType, .keychain)
    }
    
    func testCustomStorageType() {
        // Given
        let manager = AuthStorageManager(storageType: .userDefaults)
        
        // Then
        XCTAssertEqual(manager.storageType, .userDefaults)
    }
    
    // MARK: - Integration Tests
    
    func testCompleteAuthenticationFlow() {
        // Given - user logs in
        sut.storeTokens(accessToken: "access123", refreshToken: "refresh456")
        
        // Then - should be authenticated
        XCTAssertTrue(sut.isAuthenticated())
        XCTAssertEqual(sut.getAccessToken(), "access123")
        
        // When - user logs out
        sut.clearSession()
        
        // Then - should not be authenticated
        XCTAssertFalse(sut.isAuthenticated())
        XCTAssertNil(sut.getAccessToken())
    }
    
    func testTokenRefreshFlow() {
        // Given - initial tokens
        sut.storeTokens(accessToken: "old_access", refreshToken: "old_refresh")
        XCTAssertEqual(sut.getAccessToken(), "old_access")
        
        // When - tokens refreshed
        sut.storeTokens(accessToken: "new_access", refreshToken: "new_refresh")
        
        // Then - should have new tokens
        XCTAssertEqual(sut.getAccessToken(), "new_access")
    }
}

// MARK: - Mock Local Storage

final class MockLocalStorage: LocalStorageProtocol {
    var storedValues: [String: Any] = [:]
    
    func store(_ value: String, forKey key: String) {
        storedValues[key] = value
    }
    
    func store(_ value: Data, forKey key: String) {
        storedValues[key] = value
    }
    
    func getString(forKey key: String) -> String? {
        return storedValues[key] as? String
    }
    
    func getData(forKey key: String) -> Data? {
        return storedValues[key] as? Data
    }
    
    func remove(forKey key: String) {
        storedValues.removeValue(forKey: key)
    }
    
    func removeAll() {
        storedValues.removeAll()
    }
    
    func exists(forKey key: String) -> Bool {
        return storedValues[key] != nil
    }
}
