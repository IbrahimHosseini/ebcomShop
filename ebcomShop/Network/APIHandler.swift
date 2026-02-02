//
//  APIHandler.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

/// Protocol for handling low-level network operations
///
/// This protocol abstracts the actual network request execution,
/// making it easier to test and potentially swap implementations.
/// The main responsibility is to execute URLRequest objects and
/// return the raw response data.
///
/// ## Design Benefits:
/// - **Testability**: Easy to mock for unit tests
/// - **Flexibility**: Can swap implementations (URLSession, Alamofire, etc.)
/// - **Separation of Concerns**: Isolates network execution from business logic
protocol APIHandler {
    /// Executes a network request and returns raw response data
    ///
    /// This method performs the actual network call using the provided URLRequest.
    /// It's designed to be implementation-agnostic, focusing solely on the
    /// network transport layer.
    ///
    /// - Parameter request: The configured URLRequest to execute
    /// - Returns: A tuple containing the response data and URLResponse metadata
    /// - Throws: Network-related errors (connection issues, timeouts, etc.)
    ///
    /// ## Usage Example:
    /// ```swift
    /// let handler = APIHandlerImpl()
    /// let request = URLRequest(url: URL(string: "https://api.example.com/users")!)
    /// let (data, response) = try await handler.getData(with: request)
    /// ```
    func getData(with request: URLRequest) async throws -> (Data, URLResponse)
}

/// Default implementation of APIHandler using URLSession
///
/// This implementation uses the standard URLSession for network operations.
/// It's suitable for most use cases and provides a solid foundation for
/// HTTP/HTTPS requests with proper error handling and response validation.
///
/// ## Features:
/// - Uses URLSession.shared for simplicity
/// - Supports async/await for modern Swift concurrency
/// - Handles all standard URLSession errors
/// - Returns both data and response metadata
///
/// ## Customization Options:
/// You can create custom implementations for:
/// - Different URLSession configurations
/// - Custom certificate pinning
/// - Request/response logging
/// - Retry logic
/// - Custom authentication handling
final class APIHandlerImpl: APIHandler {
    /// Executes the network request using URLSession
    ///
    /// This implementation uses URLSession.shared.data(for:) to perform
    /// the actual network request. The method is marked as async and
    /// throws to properly handle Swift concurrency and error propagation.
    ///
    /// - Parameter request: The URLRequest to execute
    /// - Returns: Raw data and response from the server
    /// - Throws: URLSession errors (network issues, timeouts, etc.)
    ///
    /// ## Error Handling:
    /// URLSession can throw various errors including:
    /// - Network connectivity issues
    /// - DNS resolution failures
    /// - SSL/TLS certificate errors
    /// - Request timeouts
    /// - Server unavailability
    func getData(with request: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request)
    }
}
