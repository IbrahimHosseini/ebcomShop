//
//  establishes.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

/// Protocol defining the structure of API endpoints
///
/// This protocol establishes the contract that all API endpoints must follow.
/// It provides a standardized way to define API requests with all necessary
/// components including URL, HTTP method, headers, and request body.
///
/// ## Implementation Requirements:
/// Conforming types must provide implementations for:
/// - `path`: The specific endpoint path
/// - Custom `method`, `headers`, or `httpBody` if different from defaults
///
/// ## Default Implementations:
/// - `baseURL`: Uses the app's configuration base URL
/// - `method`: Defaults to GET requests
/// - `headers`: Standard JSON headers
/// - `httpBody`: Empty dictionary for requests without body
protocol APIEndpoint {
    /// The base URL for all API requests
    ///
    /// This property defines the root URL for the API server.
    /// It's typically loaded from the app's configuration or environment.
    var baseURL: String { get }

    /// The specific path for this endpoint
    ///
    /// This should be the path component that gets appended to the base URL.
    /// For example: "/users", "/tasks", "/auth/login"
    var path: String { get }

    /// The HTTP method for this request
    ///
    /// Specifies which HTTP method to use (GET, POST, PUT, PATCH, DELETE).
    /// Defaults to GET if not overridden.
    var method: HTTPMethod { get }

    /// HTTP headers for the request
    ///
    /// Dictionary of header key-value pairs to include in the request.
    /// Defaults to standard JSON headers if not overridden.
    var headers: [String: String]? { get }

    /// set the API parameters
    var body: [String: Any]? { get }

    /// Whether this endpoint requires authentication
    ///
    /// If true, the Authorization header with Bearer token will be added automatically.
    /// Defaults to true for security - override to false for public endpoints.
    var requiresAuthentication: Bool { get }
}

// MARK: - Default Implementations

extension APIEndpoint {
    /// Default base URL loaded from app configuration
    ///
    /// This implementation uses NetworkConfiguration to provide
    /// a centralized, configurable base URL that can be changed at runtime.
    var baseURL: String {
        NetworkConfiguration.shared.baseURL
    }

    /// Default HTTP method is GET
    ///
    /// Most API endpoints are GET requests for data retrieval.
    /// Override this property for endpoints that need other methods.
    var method: HTTPMethod { .get }

    /// Default headers for JSON API requests
    ///
    /// Sets up standard headers for JSON-based API communication:
    /// - Accept: Tells server we expect JSON responses
    /// - Content-Type: Tells server we're sending JSON data
    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    /// The `var httpBody: [String: Any]? { [:] }` line in the `APIEndpoint` protocol extension is
    /// providing a default implementation for the `httpBody` property. It is setting the default value
    /// of `httpBody` to an empty dictionary `[:]`. This means that if a specific API endpoint
    /// conforming to the `APIEndpoint` protocol does not provide a custom implementation for the
    /// `httpBody` property, it will default to an empty dictionary when creating the API request.
    var body: [String: Any]? { [:] }

    /// Default to requiring authentication for all endpoints
    ///
    /// Override this property to return false for public endpoints like login, register, etc.
    var requiresAuthentication: Bool { true }
}

// MARK: - URLRequest Conversion

extension APIEndpoint {
    /// Converts the endpoint configuration into a URLRequest
    ///
    /// This method combines all the endpoint properties (URL, method, headers, body)
    /// into a complete URLRequest object that can be used with URLSession.
    ///
    /// - Returns: A configured URLRequest ready for network execution
    /// - Throws: An error if URL construction fails
    ///
    /// ## Process:
    /// 1. Combines baseURL and path to create the complete URL
    /// 2. Sets the HTTP method
    /// 3. Applies all headers
    /// 4. Serializes the body to JSON data if present
    ///
    /// ## Usage Example:
    /// ```swift
    /// enum UserEndpoint: APIEndpoint {
    ///     case getUser(id: String)
    ///
    ///     var path: String {
    ///         case .getUser(let id): return "/users/\(id)"
    ///     }
    /// }
    ///
    /// let endpoint = UserEndpoint.getUser(id: "123")
    /// let request = try endpoint.asURLRequest()
    /// ```
    func asURLRequest() throws -> URLRequest {
        // Validate base URL before constructing the full URL
        let trimmedBaseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedBaseURL.isEmpty else {
            let errorMessage = "Base URL is empty. Check NetworkConfiguration.baseURL"
            OSLogger.error("APIEndpoint: \(errorMessage)")
            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }

        // Ensure base URL has a valid scheme
        guard trimmedBaseURL.hasPrefix("http://") || trimmedBaseURL.hasPrefix("https://") else {
            let errorMessage = "Base URL must start with http:// or https://. Got: '\(trimmedBaseURL)'"
            OSLogger.error("APIEndpoint: \(errorMessage)")
            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }

        // Validate that base URL can be parsed as a URL
        guard let baseURLObject = URL(string: trimmedBaseURL), baseURLObject.host != nil else {
            let errorMessage = "Base URL is invalid or missing host: '\(trimmedBaseURL)'"
            OSLogger.error("APIEndpoint: \(errorMessage)")
            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }

        // Ensure we have exactly one separator between base URL and path
        let sanitizedPath: String = if path.hasPrefix("/") {
            path
        } else {
            "/" + path
        }

        let finalBaseURL = trimmedBaseURL.hasSuffix("/") ? String(trimmedBaseURL.dropLast()) : trimmedBaseURL
        let urlString = finalBaseURL + sanitizedPath

        // Validate the complete URL
        guard let url = URL(string: urlString) else {
            let errorMessage = "Failed to construct URL from base: '\(finalBaseURL)' and path: '\(sanitizedPath)'"
            OSLogger.error("APIEndpoint: \(errorMessage)")
            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }

        // Log the constructed URL for debugging (only in debug builds)
        #if DEBUG
            OSLogger.info("APIEndpoint: Constructed URL: \(urlString)")
        #endif

        // Create the URLRequest with the complete URL
        var request = URLRequest(url: url)

        // Set the HTTP method (GET, POST, etc.)
        request.httpMethod = method.rawValue

        // Apply all headers to the request
        request.allHTTPHeaderFields = headers

        // Apply raw body if provided
        request.httpBody = body?.jsonData

        return request
    }
}
