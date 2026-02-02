//
//  ResponseHandler.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

/// Protocol for handling API response parsing and decoding
///
/// This protocol abstracts the response processing logic, separating
/// the concerns of network execution from data parsing. It's responsible
/// for converting raw response data into strongly-typed Swift models.
///
/// ## Design Benefits:
/// - **Type Safety**: Ensures responses are properly typed
/// - **Error Handling**: Provides structured error reporting for parsing failures
/// - **Testability**: Easy to mock for unit tests with different response scenarios
/// - **Flexibility**: Can support different parsing strategies or data formats
protocol ResponseHandler {
    /// Parses raw response data into a specified Codable type
    ///
    /// This method takes raw data from a network response and attempts to
    /// decode it into the specified Swift type using JSONDecoder.
    ///
    /// - Parameters:
    ///   - type: The target type to decode the data into (must conform to Decodable)
    ///   - data: The raw response data from the network request
    /// - Returns: A Result containing either the decoded model or a NetworkError
    ///
    /// ## Usage Example:
    /// ```swift
    /// struct User: Codable { let id: String, name: String }
    ///
    /// let handler = ResponseHandlerImpl()
    /// let result = await handler.getResponse(type: User.self, data: responseData)
    ///
    /// switch result {
    /// case .success(let user):
    ///     print("User: \(user.name)")
    /// case .failure(let error):
    ///     print("Parsing failed: \(error)")
    /// }
    /// ```
    func getResponse<T: Decodable & Sendable>(type: T.Type, data: Data) async -> ResponseResult<T>
}

/// Default implementation of ResponseHandler using JSONDecoder
///
/// This implementation provides standard JSON parsing capabilities using
/// Swift's built-in JSONDecoder. It handles common decoding scenarios and
/// provides appropriate error mapping for debugging purposes.
///
/// ## Features:
/// - Uses JSONDecoder for standard JSON parsing
/// - Maps decoding errors to structured NetworkError cases
/// - Supports all Codable types
/// - Async-compatible for modern Swift concurrency
///
/// ## Customization Options:
/// You can extend this implementation to support:
/// - Custom date formatting strategies
/// - Snake_case to camelCase key conversion
/// - Custom decoding strategies for specific data types
/// - Response validation before decoding
/// - Detailed error logging and debugging information
final class ResponseHandlerImpl: ResponseHandler {
    /// The JSONDecoder instance used for parsing responses
    ///
    /// This decoder can be customized with different strategies for
    /// date parsing, key conversion, and other decoding behaviors.
    private let decoder: JSONDecoder

    /// Initializes the response handler with a configured JSONDecoder
    ///
    /// - Parameter decoder: Optional custom JSONDecoder instance.
    ///                     If not provided, uses a default decoder with ISO8601 date decoding strategy.
    init(decoder: JSONDecoder? = nil) {
        if let decoder = decoder {
            self.decoder = decoder
        } else {
            let defaultDecoder = JSONDecoder()
            defaultDecoder.dateDecodingStrategy = .iso8601
            self.decoder = defaultDecoder
        }
    }

    /// Attempts to decode raw data into the specified type
    ///
    /// This method uses JSONDecoder to parse the raw response data into
    /// a strongly-typed Swift model. If decoding fails, it maps the error
    /// to a NetworkError.decodingFailed case for consistent error handling.
    ///
    /// - Parameters:
    ///   - type: The target Decodable type
    ///   - data: Raw JSON data from the network response
    /// - Returns: Result with either the decoded model or a decoding error
    ///
    /// ## Error Scenarios:
    /// - Invalid JSON format
    /// - Missing required fields
    /// - Type mismatches between JSON and Swift model
    /// - Custom decoding failures from the model's init(from decoder:)
    func getResponse<T: Decodable & Sendable>(type: T.Type, data: Data) async -> ResponseResult<T> {
        do {
            let response = try decoder.decode(type.self, from: data)
            return .success(response)
        } catch {
            // Log the actual decoding error for debugging
            OSLogger.error("Decoding Error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                OSLogger.error("Raw JSON: \(jsonString)")
            }

            return .failure(.decodingFailed)
        }
    }
}
