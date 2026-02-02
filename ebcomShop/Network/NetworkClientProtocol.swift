//
//  NetworkClientProtocol.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

/// A lightweight, testable abstraction for performing network requests and decoding responses.
///
/// Conformers encapsulate transport details (e.g., URLSession configuration, authentication,
/// retry/backoff, reachability) while exposing a single, strongly-typed async API. This enables
/// higher layers (repositories/services) to depend on a simple contract, swap implementations,
/// and mock responses in tests.
///
/// Responsibilities:
/// - Execute a request described by an `APIEndpoint`.
/// - Decode the response body into a caller‑provided `Decodable` type.
/// - Surface failures as a `NetworkError` without throwing, via `Result`.
///
/// Threading and Concurrency:
/// - The API is `async` and safe to call from any actor or thread.
/// - Implementations may be isolated to an actor or use `URLSession` under the hood.
/// - Callers should `await` the result and update UI on the main actor as needed.
///
/// Error Handling:
/// - Network and decoding failures are returned as `.failure(NetworkError)`.
/// - Success returns a fully decoded model of type `T: Decodable`.
///
/// Usage Example:
/// ```swift
/// let result: Result<User, NetworkError> = await client.request(.getUser(id: id))
/// switch result {
/// case .success(let user):
///     // Use decoded `user`
/// case .failure(let error):
///     // Present or log `error`
/// }
/// ```
///
/// Testing:
/// - Provide a fake/mock implementation that returns predetermined `Result` values
///   to simulate success, decoding errors, timeouts, or server errors.
///
/// See Also:
/// - `APIEndpoint` for describing requests (path, method, headers, body, query).
/// - `NetworkError` for the error taxonomy surfaced by implementations.
///
/// Method Summary:
/// - `request(_: ) async -> ResponseResult`
///   - Executes the given endpoint and decodes the response to `T`.
///   - Parameters:
///     - endpoint: An `APIEndpoint` describing the request to perform.
///   - Returns: A `Result` containing the decoded `T` on success or a `NetworkError` on failure.
///
protocol NetworkClientProtocol {
    /// The specific endpoint type this client handles
    ///
    /// This associated type creates a relationship between the client
    /// and its supported endpoints. It ensures type safety by requiring
    /// that the endpoint parameter in request methods matches this type.
    ///
    /// ## Benefits:
    /// - **Compile-time Safety**: Prevents passing wrong endpoint types
    /// - **Code Organization**: Groups related endpoints with their client
    /// - **IntelliSense Support**: Better autocomplete and error detection
    associatedtype EndpointType: APIEndpoint

    /// Executes a network request for the specified endpoint
    ///
    /// This method is the core of the API client, responsible for:
    /// 1. Converting the endpoint to a URLRequest
    /// 2. Executing the network call
    /// 3. Processing the response
    /// 4. Handling errors appropriately
    /// 5. Returning a type-safe result
    ///
    /// - Parameter endpoint: The API endpoint to request
    /// - Returns: A Result containing either the decoded response or a NetworkError
    ///
    /// ## Type Safety:
    /// The generic `T` parameter ensures that callers specify the expected
    /// response type, enabling automatic JSON decoding and compile-time
    /// type checking.
    ///
    /// ## Error Handling:
    /// All network-related errors are mapped to NetworkError cases,
    /// providing consistent error handling across the application.
    ///
    /// ## Async/Await:
    /// Uses modern Swift concurrency for clean, readable asynchronous code
    /// without callback hell or complex completion handlers.
    ///
    /// ## Usage Example:
    /// ```swift
    /// let client = UserAPIClient()
    /// let result: Result<User, NetworkError> = await client.request(.getUser(id: "123"))
    ///
    /// switch result {
    /// case .success(let user):
    ///     print("Retrieved user: \(user.name)")
    /// case .failure(let error):
    ///     print("Request failed: \(error.localizedDescription)")
    /// }
    /// ```
    func request<T: Decodable>(_ endpoint: EndpointType) async -> ResponseResult<T>
}
