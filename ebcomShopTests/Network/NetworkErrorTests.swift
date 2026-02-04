//
//  NetworkErrorTests.swift
//  ebcomShopTests
//
//  Created by Ibrahim on 2026-02-04.
//

import XCTest
@testable import ebcomShop

final class NetworkErrorTests: XCTestCase {
    
    // MARK: - Error Description Tests
    
    func testInvalidURLErrorDescription() {
        let error = NetworkError.invalidURL
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }
    
    func testNoDataErrorDescription() {
        let error = NetworkError.noData
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }
    
    func testDecodingFailedErrorDescription() {
        let error = NetworkError.decodingFailed
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }
    
    func testBadRequestErrorDescription() {
        let error = NetworkError.badRequest
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }
    
    func testNotFoundErrorDescription() {
        let error = NetworkError.notFound
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }
    
    func testAuthorizationFailedErrorDescription() {
        let error = NetworkError.authorizationFailed
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }
    
    func testServerErrorErrorDescription() {
        let error = NetworkError.serverError
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }
    
    func testTimeoutErrorDescription() {
        let error = NetworkError.timeout
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }
    
    func testNoInternetConnectionErrorDescription() {
        let error = NetworkError.noInternetConnection
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }
    
    // MARK: - Error Code Tests
    
    func testInvalidURLErrorCode() {
        let error = NetworkError.invalidURL
        XCTAssertEqual(error.errorCode, -1001)
    }
    
    func testNoDataErrorCode() {
        let error = NetworkError.noData
        XCTAssertEqual(error.errorCode, -1002)
    }
    
    func testDecodingFailedErrorCode() {
        let error = NetworkError.decodingFailed
        XCTAssertEqual(error.errorCode, -1003)
    }
    
    func testBadRequestErrorCode() {
        let error = NetworkError.badRequest
        XCTAssertEqual(error.errorCode, 400)
    }
    
    func testNotFoundErrorCode() {
        let error = NetworkError.notFound
        XCTAssertEqual(error.errorCode, 404)
    }
    
    func testAuthorizationFailedErrorCode() {
        let error = NetworkError.authorizationFailed
        XCTAssertEqual(error.errorCode, 401)
    }
    
    func testServerErrorCode() {
        let error = NetworkError.serverError
        XCTAssertEqual(error.errorCode, 500)
    }
    
    func testTimeoutErrorCode() {
        let error = NetworkError.timeout
        XCTAssertEqual(error.errorCode, -1004)
    }
    
    func testNoInternetConnectionErrorCode() {
        let error = NetworkError.noInternetConnection
        XCTAssertEqual(error.errorCode, -1005)
    }
    
    // MARK: - Equatable Tests
    
    func testErrorEquality() {
        XCTAssertEqual(NetworkError.invalidURL, NetworkError.invalidURL)
        XCTAssertEqual(NetworkError.noData, NetworkError.noData)
        XCTAssertNotEqual(NetworkError.invalidURL, NetworkError.noData)
    }
    
    // MARK: - LocalizedError Tests
    
    func testLocalizedDescriptionUsesErrorDescription() {
        let error = NetworkError.notFound
        let localizedDescription = error.localizedDescription
        XCTAssertFalse(localizedDescription.isEmpty)
    }
}
