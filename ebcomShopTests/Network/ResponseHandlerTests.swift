//
//  ResponseHandlerTests.swift
//  ebcomShopTests
//
//  Created by Ibrahim on 2026-02-04.
//

import XCTest
@testable import ebcomShop

final class ResponseHandlerTests: XCTestCase {
    private var sut: ResponseHandlerImpl!
    
    override func setUp() {
        super.setUp()
        sut = ResponseHandlerImpl()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Successful Decoding Tests
    
    func testGetResponseDecodesValidJSON() async {
        // Given
        struct TestModel: Codable, Sendable {
            let name: String
            let age: Int
        }
        
        let json = """
        {
            "name": "John",
            "age": 30
        }
        """
        let data = json.data(using: .utf8)!
        
        // When
        let result: ResponseResult<TestModel> = await sut.getResponse(type: TestModel.self, data: data)
        
        // Then
        switch result {
        case .success(let model):
            XCTAssertEqual(model.name, "John")
            XCTAssertEqual(model.age, 30)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
    
    func testGetResponseDecodesNestedJSON() async {
        // Given
        struct Address: Codable, Sendable {
            let city: String
            let country: String
        }
        
        struct User: Codable, Sendable {
            let name: String
            let address: Address
        }
        
        let json = """
        {
            "name": "John",
            "address": {
                "city": "New York",
                "country": "USA"
            }
        }
        """
        let data = json.data(using: .utf8)!
        
        // When
        let result: ResponseResult<User> = await sut.getResponse(type: User.self, data: data)
        
        // Then
        switch result {
        case .success(let user):
            XCTAssertEqual(user.name, "John")
            XCTAssertEqual(user.address.city, "New York")
            XCTAssertEqual(user.address.country, "USA")
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
    
    func testGetResponseDecodesArray() async {
        // Given
        struct Item: Codable, Sendable {
            let id: String
            let name: String
        }
        
        let json = """
        [
            {"id": "1", "name": "Item 1"},
            {"id": "2", "name": "Item 2"}
        ]
        """
        let data = json.data(using: .utf8)!
        
        // When
        let result: ResponseResult<[Item]> = await sut.getResponse(type: [Item].self, data: data)
        
        // Then
        switch result {
        case .success(let items):
            XCTAssertEqual(items.count, 2)
            XCTAssertEqual(items[0].id, "1")
            XCTAssertEqual(items[1].name, "Item 2")
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
    
    func testGetResponseDecodesEmptyObject() async {
        // Given
        struct EmptyModel: Codable, Sendable {}
        
        let json = "{}"
        let data = json.data(using: .utf8)!
        
        // When
        let result: ResponseResult<EmptyModel> = await sut.getResponse(type: EmptyModel.self, data: data)
        
        // Then
        switch result {
        case .success:
            XCTAssert(true, "Successfully decoded empty object")
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
    
    func testGetResponseDecodesOptionalFields() async {
        // Given
        struct ModelWithOptionals: Codable, Sendable {
            let required: String
            let optional: String?
        }
        
        let json = """
        {
            "required": "value"
        }
        """
        let data = json.data(using: .utf8)!
        
        // When
        let result: ResponseResult<ModelWithOptionals> = await sut.getResponse(type: ModelWithOptionals.self, data: data)
        
        // Then
        switch result {
        case .success(let model):
            XCTAssertEqual(model.required, "value")
            XCTAssertNil(model.optional)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
    
    // MARK: - Failed Decoding Tests
    
    func testGetResponseFailsWithInvalidJSON() async {
        // Given
        struct TestModel: Codable, Sendable {
            let name: String
        }
        
        let invalidJSON = "{ invalid json }"
        let data = invalidJSON.data(using: .utf8)!
        
        // When
        let result: ResponseResult<TestModel> = await sut.getResponse(type: TestModel.self, data: data)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error, .decodingFailed)
        }
    }
    
    func testGetResponseFailsWithMissingRequiredField() async {
        // Given
        struct TestModel: Codable, Sendable {
            let name: String
            let age: Int
        }
        
        let json = """
        {
            "name": "John"
        }
        """
        let data = json.data(using: .utf8)!
        
        // When
        let result: ResponseResult<TestModel> = await sut.getResponse(type: TestModel.self, data: data)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error, .decodingFailed)
        }
    }
    
    func testGetResponseFailsWithTypeMismatch() async {
        // Given
        struct TestModel: Codable, Sendable {
            let age: Int
        }
        
        let json = """
        {
            "age": "thirty"
        }
        """
        let data = json.data(using: .utf8)!
        
        // When
        let result: ResponseResult<TestModel> = await sut.getResponse(type: TestModel.self, data: data)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error, .decodingFailed)
        }
    }
    
    func testGetResponseFailsWithEmptyData() async {
        // Given
        struct TestModel: Codable, Sendable {
            let name: String
        }
        
        let data = Data()
        
        // When
        let result: ResponseResult<TestModel> = await sut.getResponse(type: TestModel.self, data: data)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error, .decodingFailed)
        }
    }
    
    // MARK: - Custom Decoder Tests
    
    func testGetResponseWithCustomDecoder() async {
        // Given
        struct TestModel: Codable, Sendable {
            let createdAt: Date
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let customHandler = await ResponseHandlerImpl(decoder: decoder)
        
        let json = """
        {
            "createdAt": "2024-01-15T10:30:00Z"
        }
        """
        let data = json.data(using: .utf8)!
        
        // When
        let result: ResponseResult<TestModel> = await customHandler.getResponse(type: TestModel.self, data: data)
        
        // Then
        switch result {
        case .success(let model):
            XCTAssertNotNil(model.createdAt)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
    
    func testGetResponseUsesDefaultISO8601DateStrategy() async {
        // Given
        struct TestModel: Codable, Sendable {
            let date: Date
        }
        
        let json = """
        {
            "date": "2024-01-15T10:30:00Z"
        }
        """
        let data = json.data(using: .utf8)!
        
        // When
        let result: ResponseResult<TestModel> = await sut.getResponse(type: TestModel.self, data: data)
        
        // Then
        switch result {
        case .success(let model):
            XCTAssertNotNil(model.date)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
}
