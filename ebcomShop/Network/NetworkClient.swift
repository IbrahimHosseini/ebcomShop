//
//  provides.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

/// Generic network client implementation
///
/// This class provides a concrete implementation of the APIClient protocol,
/// serving as the primary network layer for the application. It orchestrates
/// the interaction between different network components to provide a complete
/// request/response cycle.
///
/// ## Architecture:
/// The NetworkClient follows a layered architecture:
/// 1. **Endpoint Layer**: Defines API endpoints and their configurations
/// 2. **Request Layer**: Converts endpoints to URLRequests (APIHandler)
/// 3. **Transport Layer**: Executes network requests (APIHandler)
/// 4. **Response Layer**: Parses and validates responses (ResponseHandler)
/// 5. **Error Layer**: Maps errors to domain-specific types (NetworkError)
///
/// ## Generic Design:
/// The class is generic over `EndpointType`, allowing you to create
/// specialized clients for different API services while sharing the
/// same underlying network logic.
///
/// ## Usage Examples:
/// ```swift
/// // For user-related API calls
/// let userClient = NetworkClient<UserEndpoints>()
/// let user: Result<User, NetworkError> = await userClient.request(.getUser(id: "123"))
///
/// // For task-related API calls
/// let taskClient = NetworkClient<TaskEndpoints>()
/// let tasks: Result<[Task], NetworkError> = await taskClient.request(.getAllTasks)
/// ```
final class NetworkClient<EndpointType: APIEndpoint>: NetworkClientProtocol {
    // MARK: - Dependencies

    /// Handles low-level network request execution
    private let apiHandler: APIHandler

    /// Handles response parsing and validation
    private let responseHandler: ResponseHandler

    // MARK: - Initialization

    /// Creates a new NetworkClient with the specified handlers
    ///
    /// This initializer allows for dependency injection, making the client
    /// easily testable and configurable for different environments.
    ///
    /// - Parameters:
    ///   - apiHandler: The handler responsible for executing network requests.
    ///                Defaults to APIHandlerImpl() for production use.
    ///   - responseHandler: The handler responsible for parsing responses.
    ///                     Defaults to ResponseHandlerImpl() for standard JSON parsing.
    ///
    /// ## Dependency Injection Benefits:
    /// - **Testing**: Inject mock handlers for unit tests
    /// - **Flexibility**: Use different implementations for different environments
    /// - **Configuration**: Customize behavior without modifying the client
    ///
    /// ## Example with Custom Handlers:
    /// ```swift
    /// let customDecoder = JSONDecoder()
    /// customDecoder.dateDecodingStrategy = .iso8601
    ///
    /// let responseHandler = ResponseHandlerImpl(decoder: customDecoder)
    /// let client = NetworkClient<UserEndpoints>(responseHandler: responseHandler)
    /// ```
    init(
        apiHandler: APIHandler = APIHandlerImpl(),
        responseHandler: ResponseHandler = ResponseHandlerImpl()
    ) {
        self.apiHandler = apiHandler
        self.responseHandler = responseHandler
    }

    // MARK: - APIClient Implementation

    /// Executes a network request for the specified endpoint
    ///
    /// This method implements the complete request/response cycle:
    /// 1. **Request Creation**: Converts the endpoint to a URLRequest
    /// 2. **Network Execution**: Performs the actual HTTP request
    /// 3. **Response Validation**: Checks HTTP status codes
    /// 4. **Data Parsing**: Decodes the response into the requested type
    /// 5. **Error Mapping**: Converts various error types to NetworkError
    ///
    /// - Parameter endpoint: The API endpoint configuration to execute
    /// - Returns: A Result containing either the decoded response or a NetworkError
    ///
    /// ## HTTP Status Code Handling:
    /// - **2xx**: Success - proceeds to parse response data
    /// - **401**: Unauthorized - maps to `.authorizationFailed`
    /// - **404**: Not Found - maps to `.notFound`
    /// - **5xx**: Server Error - maps to `.serverError`
    /// - **Other 4xx**: Client Error - maps to `.badRequest`
    ///
    /// ## Error Scenarios:
    /// - Invalid endpoint configuration → `.badRequest`
    /// - Network connectivity issues → `.noData`
    /// - JSON parsing failures → `.decodingFailed`
    /// - HTTP error status codes → Appropriate NetworkError case
    ///
    /// ## Usage Example:
    /// ```swift
    /// let client = NetworkClient<TaskEndpoints>()
    ///
    /// let result: Result<[Task], NetworkError> = await client.request(.getAllTasks)
    /// switch result {
    /// case .success(let tasks):
    ///     // Handle successful response
    ///     updateUI(with: tasks)
    /// case .failure(let error):
    ///     // Handle error appropriately
    ///     showError(error.localizedDescription)
    /// }
    /// ```
    func request<T: Decodable>(_ endpoint: EndpointType) async -> ResponseResult<T> {
        // Step 1: Convert endpoint to URLRequest
        guard var request = try? endpoint.asURLRequest() else {
            return .failure(.badRequest)
        }
        
        // Step 2: Add Authorization header if endpoint requires authentication
        if endpoint.requiresAuthentication {
            do {
                let accessToken = try await AuthSessionManager.shared.getValidAccessToken()
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } catch {
                OSLogger.error("Failed to get access token: \(error.localizedDescription)")
                // If we can't get a token, handle as unauthorized
                await AuthSessionManager.shared.handleUnauthorized()
                return .failure(.authorizationFailed)
            }
        }
        
        OSLogger.info("request.url: \(String(describing: request.url))")
        OSLogger.info("request.httpBody: \(String(describing: request.httpBody))")
        OSLogger.info("request.httpMethod: \(String(describing: request.httpMethod))")

        do {
            // Step 3: Execute the network request
            let (data, urlResponse) = try await apiHandler.getData(with: request)

            // Step 4: Validate the response type
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return .failure(.badRequest)
            }
            
            OSLogger.info("httpResponse.statusCode: \(httpResponse.statusCode)")

            // Step 5: Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200 ..< 300:
                // Success: Parse the response data
                let parseResult = await responseHandler.getResponse(type: T.self, data: data)
                switch parseResult {
                case .success(let model):
                    return .success(model)
                case .failure(let error):
                    return .failure(error)
                }

            case 401, 403:
                // Authentication/Authorization failed
                // Log error details from backend for debugging
                if let errorString = String(data: data, encoding: .utf8) {
                    OSLogger.error("Authorization failed - Backend response: \(errorString)")
                }
                // Handle unauthorized globally - this will clear session and notify app
                await AuthSessionManager.shared.handleUnauthorized()
                return .failure(.authorizationFailed)

            case 404:
                // Resource not found
                return .failure(.notFound)

            case 500 ..< 600:
                // Server error
                return .failure(.serverError)

            default:
                // Other client errors
                return .failure(.badRequest)
            }

        } catch {
            // Network-level errors (connectivity, timeout, etc.)
            return .failure(.noData)
        }
    }
}
