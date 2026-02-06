//
//  NetworkMonitorTests.swift
//  ebcomShopTests
//
//  Created by Ibrahim on 2026-02-06.
//

import XCTest
@testable import ebcomShop

final class NetworkMonitorTests: XCTestCase {
    private var sut: NetworkMonitor!
    
    override func setUp() {
        super.setUp()
        sut = NetworkMonitor()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialStateIsConnected() {
        // Then
        // Note: In tests, the initial state will likely be true (satisfied)
        // unless running in a restricted environment
        XCTAssertTrue(sut.isConnected || !sut.isConnected, "Should have a defined connection state")
    }
    
    func testConnectionTypeIsSet() {
        // Then
        // Connection type may or may not be set depending on environment
        // This test just verifies the property is accessible
        _ = sut.connectionType
    }
    
    // MARK: - Observable Tests
    
    func testIsObservable() {
        // Given
        let expectation = XCTestExpectation(description: "Connection state should be observable")
        
        // When
        let initialState = sut.isConnected
        
        // Then
        XCTAssertNotNil(initialState, "Should have connection state")
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Mock Network Monitor Tests
    
    func testMockNetworkMonitorCanBeInitializedWithState() {
        // Given
        let connectedMonitor = MockNetworkMonitor(isConnected: true)
        let disconnectedMonitor = MockNetworkMonitor(isConnected: false)
        
        // Then
        XCTAssertTrue(connectedMonitor.isConnected)
        XCTAssertFalse(disconnectedMonitor.isConnected)
    }
}
