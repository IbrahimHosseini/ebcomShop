//
//  NetworkClientTests.swift
//  ebcomShopTests
//
//  Created by Ibrahim on 2026-02-04.
//

import XCTest
@testable import ebcomShop

final class NetworkClientTests: XCTestCase {
    private var sut: NetworkClient<MockEndpoint>!
    private var mockAPIHandler: MockAPIHandler!
    private var mockResponseHandler: MockResponseHandler!
    
    override func setUp() {
        super.setUp()
        mockAPIHandler = MockAPIHandler()
        mockResponseHandler = MockResponseHandler()
        sut = NetworkClient(
            apiHandler: mockAPIHandler,
            responseHandler: mockResponseHandler
        )
    }
    
    override func tearDown() {
        sut = nil
        mockAPIHandler = nil
        mockResponseHandler = nil
        super.tearDown()
    }
    
    // MARK: - Successful Request Tests
    
    func testRequestSucceedsWithValidResponse() async {
        // Given
        let expectedModel = TestModel(id: "1", name: "Test")
        mockAPIHandler.responseData = Data()
        mockAPIHandler.statusCode = 200
        mockResponseHandler.result = .success(expectedModel)
        
        // When
        let result: ResponseResult<TestModel> = await sut.request(.getData)
        
        // Then
        switch result {
        case .success(let model):
            XCTAssertEqual(model.id, "1")
            XCTAssertEqual(model.name, "Test")
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
    
    func testRequestUsesCorrectHTTPMethod() async {
        // Given
        mockAPIHandler.responseData = Data()
        mockAPIHandler.statusCode = 200
        mockResponseHandler.result = .success(TestModel(id: "1", name: "Test"))
        
        // When
        let _: ResponseResult<TestModel> = await sut.request(.postData)
        
        // Then
        XCTAssertEqual(mockAPIHandler.lastRequest?.httpMethod, "POST")
    }
    
    // MARK: - HTTP Status Code Tests
    
    func testRequestHandles200StatusCode() async {
        // Given
        mockAPIHandler.responseData = Data()
        mockAPIHandler.statusCode = 200
        mockResponseHandler.result = .success(TestModel(id: "1", name: "Test"))
        
        // When
        let result: ResponseResult<TestModel> = await sut.request(.getData)
        
        // Then
        if case .failure = result {
            XCTFail("Expected success for 200 status code")
        }
    }
    
    func testRequestHandles201StatusCode() async {
        // Given
        mockAPIHandler.responseData = Data()
        mockAPIHandler.statusCode = 201
        mockResponseHandler.result = .success(TestModel(id: "1", name: "Test"))
        
        // When
        let result: ResponseResult<TestModel> = await sut.request(.postData)
        
        // Then
        if case .failure = result {
            XCTFail("Expected success for 201 status code")
        }
    }
    
    func testRequestHandles401StatusCode() async {
        // Given
        mockAPIHandler.responseData = Data()
        mockAPIHandler.statusCode = 401
        
        // When
        let result: ResponseResult<TestModel> = await sut.request(.getData)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for 401 status code")
        case .failure(let error):
            XCTAssertEqual(error, .authorizationFailed)
        }
    }
    
    func testRequestHandles403StatusCode() async {
        // Given
        mockAPIHandler.responseData = Data()
        mockAPIHandler.statusCode = 403
        
        // When
        let result: ResponseResult<TestModel> = await sut.request(.getData)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for 403 status code")
        case .failure(let error):
            XCTAssertEqual(error, .authorizationFailed)
        }
    }
    
    func testRequestHandles404StatusCode() async {
        // Given
        mockAPIHandler.responseData = Data()
        mockAPIHandler.statusCode = 404
        
        // When
        let result: ResponseResult<TestModel> = await sut.request(.getData)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for 404 status code")
        case .failure(let error):
            XCTAssertEqual(error, .notFound)
        }
    }
    
    func testRequestHandles500StatusCode() async {
        // Given
        mockAPIHandler.responseData = Data()
        mockAPIHandler.statusCode = 500
        
        // When
        let result: ResponseResult<TestModel> = await sut.request(.getData)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for 500 status code")
        case .failure(let error):
            XCTAssertEqual(error, .serverError)
        }
    }
    
    func testRequestHandles400StatusCode() async {
        // Given
        mockAPIHandler.responseData = Data()
        mockAPIHandler.statusCode = 400
        
        // When
        let result: ResponseResult<TestModel> = await sut.request(.getData)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for 400 status code")
        case .failure(let error):
            XCTAssertEqual(error, .badRequest)
        }
    }
    
    // MARK: - Network Error Tests
    
    func testRequestFailsWhenNetworkThrows() async {
        // Given
        mockAPIHandler.shouldThrow = true
        
        // When
        let result: ResponseResult<TestModel> = await sut.request(.getData)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure when network throws")
        case .failure(let error):
            XCTAssertEqual(error, .noData)
        }
    }
    
    // MARK: - Decoding Error Tests
    
    func testRequestFailsWhenDecodingFails() async {
        // Given
        mockAPIHandler.responseData = Data()
        mockAPIHandler.statusCode = 200
        mockResponseHandler.result = .failure(.decodingFailed)
        
        // When
        let result: ResponseResult<TestModel> = await sut.request(.getData)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure when decoding fails")
        case .failure(let error):
            XCTAssertEqual(error, .decodingFailed)
        }
    }
}

// MARK: - Mock Test Models

struct TestModel: Codable, Sendable, Equatable {
    let id: String
    let name: String
}

enum MockEndpoint: APIEndpoint {
    case getData
    case postData
    case invalid
    
    var baseURL: String {
        return "https://api.example.com"
    }
    
    var path: String {
        switch self {
        case .getData, .postData:
            return "/data"
        case .invalid:
            return ""
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getData:
            return .get
        case .postData:
            return .post
        case .invalid:
            return .get
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var requiresAuthentication: Bool {
        return false
    }
}

// MARK: - Mock API Handler

final class MockAPIHandler: APIHandler {
    var responseData: Data = Data()
    var statusCode: Int = 200
    var shouldThrow: Bool = false
    var lastRequest: URLRequest?
    
    func getData(with request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        
        if shouldThrow {
            throw URLError(.notConnectedToInternet)
        }
        
        let url = request.url ?? URL(string: "https://example.com")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (responseData, response)
    }
}

// MARK: - Mock Response Handler

final class MockResponseHandler: ResponseHandler {
    var result: ResponseResult<Any> = .failure(.decodingFailed)
    
    func getResponse<T: Decodable & Sendable>(type: T.Type, data: Data) async -> ResponseResult<T> {
        switch result {
        case .success(let value):
            if let typedValue = value as? T {
                return .success(typedValue)
            }
            return .failure(.decodingFailed)
        case .failure(let error):
            return .failure(error)
        }
    }
}
