//
//  DictionaryExtensionTests.swift
//  ebcomShopTests
//
//  Created by Ibrahim on 2026-02-04.
//

import XCTest
@testable import ebcomShop

final class DictionaryExtensionTests: XCTestCase {
    
    // MARK: - trimmedString Tests
    
    func testTrimmedStringWithValidString() {
        // Given
        let dict: [String: Any] = ["key": "  value  "]
        
        // When
        let result = dict.trimmedString(forKey: "key")
        
        // Then
        XCTAssertEqual(result, "value")
    }
    
    func testTrimmedStringWithNoWhitespace() {
        // Given
        let dict: [String: Any] = ["key": "value"]
        
        // When
        let result = dict.trimmedString(forKey: "key")
        
        // Then
        XCTAssertEqual(result, "value")
    }
    
    func testTrimmedStringWithOnlyWhitespace() {
        // Given
        let dict: [String: Any] = ["key": "   "]
        
        // When
        let result = dict.trimmedString(forKey: "key")
        
        // Then
        XCTAssertEqual(result, "")
    }
    
    func testTrimmedStringWithNewlines() {
        // Given
        let dict: [String: Any] = ["key": "\n\nvalue\n\n"]
        
        // When
        let result = dict.trimmedString(forKey: "key")
        
        // Then
        XCTAssertEqual(result, "value")
    }
    
    func testTrimmedStringWithNonStringValue() {
        // Given
        let dict: [String: Any] = ["key": 123]
        
        // When
        let result = dict.trimmedString(forKey: "key")
        
        // Then
        XCTAssertNil(result)
    }
    
    func testTrimmedStringWithMissingKey() {
        // Given
        let dict: [String: Any] = ["key": "value"]
        
        // When
        let result = dict.trimmedString(forKey: "nonexistent")
        
        // Then
        XCTAssertNil(result)
    }
    
    // MARK: - string Tests
    
    func testStringWithValidString() {
        // Given
        let dict: [String: Any] = ["key": "value"]
        
        // When
        let result = dict.string(forKey: "key")
        
        // Then
        XCTAssertEqual(result, "value")
    }
    
    func testStringWithNonStringValue() {
        // Given
        let dict: [String: Any] = ["key": 123]
        
        // When
        let result = dict.string(forKey: "key")
        
        // Then
        XCTAssertNil(result)
    }
    
    func testStringWithMissingKey() {
        // Given
        let dict: [String: Any] = ["key": "value"]
        
        // When
        let result = dict.string(forKey: "nonexistent")
        
        // Then
        XCTAssertNil(result)
    }
    
    func testStringPreservesWhitespace() {
        // Given
        let dict: [String: Any] = ["key": "  value  "]
        
        // When
        let result = dict.string(forKey: "key")
        
        // Then
        XCTAssertEqual(result, "  value  ")
    }
    
    // MARK: - jsonData Tests
    
    func testJsonDataWithSimpleDictionary() {
        // Given
        let dict = ["name": "John", "age": 30] as [String: Any]
        
        // When
        let data = dict.jsonData
        
        // Then
        XCTAssertNotNil(data)
        
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            XCTAssertEqual(json["name"] as? String, "John")
            XCTAssertEqual(json["age"] as? Int, 30)
        } else {
            XCTFail("Failed to convert back to dictionary")
        }
    }
    
    func testJsonDataWithNestedDictionary() {
        // Given
        let dict = [
            "user": [
                "name": "John",
                "email": "john@example.com"
            ]
        ] as [String: Any]
        
        // When
        let data = dict.jsonData
        
        // Then
        XCTAssertNotNil(data)
    }
    
    func testJsonDataWithArray() {
        // Given
        let dict = ["items": ["item1", "item2", "item3"]] as [String: Any]
        
        // When
        let data = dict.jsonData
        
        // Then
        XCTAssertNotNil(data)
    }
    
    func testJsonDataWithEmptyDictionary() {
        // Given
        let dict: [String: Any] = [:]
        
        // When
        let data = dict.jsonData
        
        // Then
        XCTAssertNotNil(data)
    }
    
    // MARK: - toJSONString Tests
    
    func testToJSONStringWithSimpleDictionary() {
        // Given
        let dict = ["name": "John", "age": 30] as [String: Any]
        
        // When
        let jsonString = dict.toJSONString()
        
        // Then
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString?.contains("name") ?? false)
        XCTAssertTrue(jsonString?.contains("John") ?? false)
        XCTAssertTrue(jsonString?.contains("age") ?? false)
    }
    
    func testToJSONStringWithEmptyDictionary() {
        // Given
        let dict: [String: Any] = [:]
        
        // When
        let jsonString = dict.toJSONString()
        
        // Then
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString?.contains("{") ?? false)
        XCTAssertTrue(jsonString?.contains("}") ?? false)
    }
    
    func testToJSONStringPrettyPrinted() {
        // Given
        let dict = ["name": "John"] as [String: Any]
        
        // When
        let jsonString = dict.toJSONString()
        
        // Then
        XCTAssertNotNil(jsonString)
        // Pretty printed JSON should have newlines
        XCTAssertTrue(jsonString?.contains("\n") ?? false)
    }
    
    // MARK: - asDictionary Tests
    
    func testAsDictionaryWithEncodableStruct() {
        // Given
        struct TestModel: Codable {
            let name: String
            let age: Int
        }
        let model = TestModel(name: "John", age: 30)
        
        // When
        let dict = model.asDictionary
        
        // Then
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict?["name"] as? String, "John")
        XCTAssertEqual(dict?["age"] as? Int, 30)
    }
    
    func testAsDictionaryWithNestedStruct() {
        // Given
        struct Address: Codable {
            let city: String
            let country: String
        }
        struct User: Codable {
            let name: String
            let address: Address
        }
        let user = User(name: "John", address: Address(city: "NYC", country: "USA"))
        
        // When
        let dict = user.asDictionary
        
        // Then
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict?["name"] as? String, "John")
        XCTAssertNotNil(dict?["address"] as? [String: Any])
    }
    
    func testAsDictionaryWithEmptyStruct() {
        // Given
        struct EmptyModel: Codable {}
        let model = EmptyModel()
        
        // When
        let dict = model.asDictionary
        
        // Then
        XCTAssertNotNil(dict)
        XCTAssertTrue(dict?.isEmpty ?? false)
    }
}
