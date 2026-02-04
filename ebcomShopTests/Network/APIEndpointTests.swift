//
//  APIEndpointTests.swift
//  ebcomShopTests
//
//  Created by Ibrahim on 2026-02-04.
//

import XCTest
@testable import ebcomShop

final class APIEndpointTests: XCTestCase {
    
    // MARK: - URL Request Creation Tests
    
    func testAsURLRequestCreatesValidURLRequest() throws {
        // Given
        let endpoint = TestEndpoint.get
        
        // When
        let request = try endpoint.asURLRequest()
        
        // Then
        XCTAssertNotNil(request.url)
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func testAsURLRequestSetsCorrectHTTPMethod() throws {
        // Given
        let getEndpoint = TestEndpoint.get
        let postEndpoint = TestEndpoint.post
        let putEndpoint = TestEndpoint.put
        let deleteEndpoint = TestEndpoint.delete
        
        // When
        let getRequest = try getEndpoint.asURLRequest()
        let postRequest = try postEndpoint.asURLRequest()
        let putRequest = try putEndpoint.asURLRequest()
        let deleteRequest = try deleteEndpoint.asURLRequest()
        
        // Then
        XCTAssertEqual(getRequest.httpMethod, "GET")
        XCTAssertEqual(postRequest.httpMethod, "POST")
        XCTAssertEqual(putRequest.httpMethod, "PUT")
        XCTAssertEqual(deleteRequest.httpMethod, "DELETE")
    }
    
    func testAsURLRequestSetsDefaultHeaders() throws {
        // Given
        let endpoint = TestEndpoint.get
        
        // When
        let request = try endpoint.asURLRequest()
        
        // Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
    
    func testAsURLRequestSetsCustomHeaders() throws {
        // Given
        let endpoint = TestEndpoint.customHeaders
        
        // When
        let request = try endpoint.asURLRequest()
        
        // Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "Custom-Header"), "CustomValue")
    }
    
    func testAsURLRequestCombinesBaseURLAndPath() throws {
        // Given
        let endpoint = TestEndpoint.get
        
        // When
        let request = try endpoint.asURLRequest()
        
        // Then
        let expectedURL = "https://api.example.com/test"
        XCTAssertEqual(request.url?.absoluteString, expectedURL)
    }
    
    func testAsURLRequestHandlesPathWithoutLeadingSlash() throws {
        // Given
        let endpoint = TestEndpoint.pathWithoutSlash
        
        // When
        let request = try endpoint.asURLRequest()
        
        // Then
        XCTAssertTrue(request.url?.absoluteString.contains("/test") ?? false)
    }
    
    func testAsURLRequestHandlesBaseURLWithTrailingSlash() throws {
        // Given
        let endpoint = TestEndpoint.baseWithTrailingSlash
        
        // When
        let request = try endpoint.asURLRequest()
        
        // Then
        // Should not have double slashes
        XCTAssertFalse(request.url?.absoluteString.contains("//test") ?? true)
    }
    
    func testAsURLRequestSetsBodyForPostRequest() throws {
        // Given
        let endpoint = TestEndpoint.post
        
        // When
        let request = try endpoint.asURLRequest()
        
        // Then
        XCTAssertNotNil(request.httpBody)
        if let body = request.httpBody,
           let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
            XCTAssertEqual(json["key"] as? String, "value")
        } else {
            XCTFail("Failed to decode body")
        }
    }
    
    func testAsURLRequestDoesNotSetBodyForGetRequest() throws {
        // Given
        let endpoint = TestEndpoint.get
        
        // When
        let request = try endpoint.asURLRequest()
        
        // Then
        XCTAssertNil(request.httpBody)
    }
    
    func testAsURLRequestThrowsForInvalidBaseURL() {
        // Given
        let endpoint = TestEndpoint.invalidBaseURL
        
        // When/Then
        XCTAssertThrowsError(try endpoint.asURLRequest())
    }
    
    func testAsURLRequestThrowsForEmptyBaseURL() {
        // Given
        let endpoint = TestEndpoint.emptyBaseURL
        
        // When/Then
        XCTAssertThrowsError(try endpoint.asURLRequest())
    }
    
    func testAsURLRequestThrowsForBaseURLWithoutScheme() {
        // Given
        let endpoint = TestEndpoint.baseURLWithoutScheme
        
        // When/Then
        XCTAssertThrowsError(try endpoint.asURLRequest())
    }
    
    // MARK: - Authentication Tests
    
    func testDefaultRequiresAuthenticationIsFalse() {
        // Given
        let endpoint = TestEndpoint.get
        
        // Then
        XCTAssertFalse(endpoint.requiresAuthentication)
    }
    
    func testRequiresAuthenticationCanBeOverridden() {
        // Given
        let endpoint = TestEndpoint.authenticated
        
        // Then
        XCTAssertTrue(endpoint.requiresAuthentication)
    }
}

// MARK: - Test Endpoint

enum TestEndpoint: APIEndpoint {
    case get
    case post
    case put
    case delete
    case customHeaders
    case pathWithoutSlash
    case baseWithTrailingSlash
    case invalidBaseURL
    case emptyBaseURL
    case baseURLWithoutScheme
    case authenticated
    
    var baseURL: String {
        switch self {
        case .baseWithTrailingSlash:
            return "https://api.example.com/"
        case .invalidBaseURL:
            return "not a valid url"
        case .emptyBaseURL:
            return ""
        case .baseURLWithoutScheme:
            return "api.example.com"
        default:
            return "https://api.example.com"
        }
    }
    
    var path: String {
        switch self {
        case .pathWithoutSlash:
            return "test"
        default:
            return "/test"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .get, .customHeaders, .pathWithoutSlash, .baseWithTrailingSlash, .invalidBaseURL, .emptyBaseURL, .baseURLWithoutScheme, .authenticated:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .customHeaders:
            return ["Custom-Header": "CustomValue"]
        default:
            return ["Accept": "application/json", "Content-Type": "application/json"]
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .post, .put:
            return ["key": "value"]
        default:
            return nil
        }
    }
    
    var requiresAuthentication: Bool {
        switch self {
        case .authenticated:
            return true
        default:
            return false
        }
    }
}
