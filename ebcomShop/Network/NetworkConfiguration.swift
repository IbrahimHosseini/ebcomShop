//
//  NetworkConfiguration.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

/// Network configuration manager for API endpoints and settings
///
/// This class provides centralized configuration management for network-related
/// settings, including base URLs, timeouts, and other network parameters.
/// It supports different environments (development, staging, production) and
/// can be configured through various sources.
///
/// ## Features:
/// - Environment-specific configuration
/// - Singleton pattern for global access
/// - Support for configuration files and environment variables
/// - Runtime configuration updates
/// - Default fallback values
///
/// ## Usage Example:
/// ```swift
/// // Get the shared configuration
/// let config = NetworkConfiguration.shared
///
/// // Access configuration values
/// print("API Base URL: \(config.baseURL)")
/// print("Request Timeout: \(config.requestTimeout)")
///
/// // Update configuration at runtime
/// config.updateBaseURL("https://staging-api.lifeforge.app")
/// ```
final class NetworkConfiguration {
    // MARK: - Singleton

    /// Shared instance for global access
    ///
    /// This singleton provides a centralized point for accessing network
    /// configuration throughout the application. It's initialized once
    /// and maintains configuration state across the app lifecycle.
    static let shared = NetworkConfiguration()

    // MARK: - Configuration Properties

    /// The base URL for all API requests
    ///
    /// This URL serves as the root for all endpoint paths. It can be
    /// updated at runtime to support different environments or A/B testing.
    ///
    /// ## Default Behavior:
    /// - Attempts to load from Info.plist configuration
    /// - Falls back to production URL if not configured
    /// - Can be overridden at runtime for testing
    private(set) var baseURL: String

    /// Request timeout interval in seconds
    ///
    /// Defines how long to wait for network requests before timing out.
    /// This can be adjusted based on network conditions or API requirements.
    private(set) var requestTimeout: TimeInterval

    /// Maximum number of retry attempts for failed requests
    ///
    /// Specifies how many times to retry a failed request before giving up.
    /// Useful for handling temporary network issues or server hiccups.
    private(set) var maxRetryAttempts: Int

    /// Enable/disable network request logging
    ///
    /// Controls whether network requests and responses are logged for
    /// debugging purposes. Should be disabled in production builds.
    private(set) var isLoggingEnabled: Bool

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern
    ///
    /// Loads configuration from various sources in priority order:
    /// 1. Info.plist configuration section
    /// 2. Environment variables
    /// 3. Default fallback values
    ///
    /// ## Configuration Sources:
    /// The initializer attempts to load configuration from:
    /// - Bundle Info.plist with "NetworkConfiguration" key
    /// - Environment variables for CI/CD scenarios
    /// - Hardcoded defaults as final fallback
    private init() {
        // Initialize with default values
        self.baseURL = "https://api-lifeforge.thepixelforge.app"
        self.requestTimeout = 30.0
        self.maxRetryAttempts = 3
        self.isLoggingEnabled = false

        // Attempt to load from configuration sources
        loadConfiguration()
    }

    // MARK: - Configuration Loading

    /// Loads configuration from available sources
    ///
    /// This method loads configuration from multiple sources in priority order:
    /// 1. .xcconfig variables (injected into Bundle.main.infoDictionary)
    /// 2. Environment variables (for CI/CD scenarios)
    /// 3. Debug-specific overrides (for development builds)
    ///
    /// The loading order ensures that more specific configurations
    /// take precedence over general ones.
    private func loadConfiguration() {
        // Load directly from .xcconfig variables
        loadFromXCConfig()

        // Load from environment variables (useful for CI/CD)
        loadFromEnvironmentVariables()

        // Apply debug-specific settings
        applyDebugConfiguration()
    }

    /// Loads configuration directly from .xcconfig variables
    ///
    /// Reads configuration values directly from Bundle.main.infoDictionary,
    /// which contains all the .xcconfig variables injected during build time.
    /// This approach eliminates the need for structured Info.plist sections.
    ///
    /// ## Configuration Variables from .xcconfig:
    /// - NETWORK_BASE_URL: API base URL for network requests
    /// - NETWORK_REQUEST_TIMEOUT: Request timeout in seconds
    /// - NETWORK_MAX_RETRY_ATTEMPTS: Maximum retry attempts for failed requests
    /// - NETWORK_LOGGING_ENABLED: Whether network logging is enabled
    /// - API_BASE_URL: Fallback API base URL
    /// - ENVIRONMENT: Current environment (development/production)
    private func loadFromXCConfig() {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            OSLogger.error("NetworkConfiguration: Failed to load Info.plist")
            return
        }

        loadBaseURLFromXCConfig(infoDictionary: infoDictionary)
        loadOtherSettingsFromXCConfig(infoDictionary: infoDictionary)
        logConfigurationSummary()
    }

    /// Loads base URL from .xcconfig with fallback support
    private func loadBaseURLFromXCConfig(infoDictionary: [String: Any]) {
        // Try NETWORK_BASE_URL first
        if let networkBaseURLRaw = infoDictionary["NETWORK_BASE_URL"] as? String,
           !networkBaseURLRaw.isEmpty {
            let trimmedBaseURL = networkBaseURLRaw.trimmingCharacters(in: .whitespacesAndNewlines)
            if validateBaseURL(trimmedBaseURL) {
                baseURL = trimmedBaseURL
                return
            }
        }

        // Fallback to API_BASE_URL if needed
        if baseURL == "https://api-lifeforge.thepixelforge.app" || !validateBaseURL(baseURL) {
            tryAPIBaseURLFallback(infoDictionary: infoDictionary)
        }

        // Final validation
        if !validateBaseURL(baseURL) {
            baseURL = "https://api-lifeforge.thepixelforge.app"
        }
    }

    /// Tries to load base URL from API_BASE_URL as fallback
    private func tryAPIBaseURLFallback(infoDictionary: [String: Any]) {
        guard let apiBaseURL = infoDictionary["API_BASE_URL"] as? String,
              !apiBaseURL.isEmpty else {
            return
        }

        let trimmedBaseURL = apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if validateBaseURL(trimmedBaseURL) {
            baseURL = trimmedBaseURL
        }
    }

    /// Loads other settings (timeout, retries, logging) from .xcconfig
    private func loadOtherSettingsFromXCConfig(infoDictionary: [String: Any]) {
        // Load request timeout
        if let timeoutString = infoDictionary["NETWORK_REQUEST_TIMEOUT"] as? String,
           let timeout = Double(timeoutString) {
            requestTimeout = timeout
        }

        // Load max retry attempts
        if let retryString = infoDictionary["NETWORK_MAX_RETRY_ATTEMPTS"] as? String,
           let retry = Int(retryString) {
            maxRetryAttempts = retry
        }

        // Load logging enabled
        if let loggingString = infoDictionary["NETWORK_LOGGING_ENABLED"] as? String {
            let lowercased = loggingString.lowercased()
            isLoggingEnabled = lowercased == "yes" || lowercased == "true"
        }

        // Log environment
        if let environment = infoDictionary["ENVIRONMENT"] as? String {
            OSLogger.info("NetworkConfiguration: Environment = \(environment)")
        }
    }

    /// Logs a summary of the loaded configuration
    private func logConfigurationSummary() {
        OSLogger.info("NetworkConfiguration loaded: URL=\(baseURL), Timeout=\(requestTimeout)s")
    }

    /// Loads configuration from environment variables
    ///
    /// Checks for specific environment variables that can override
    /// configuration settings. This is particularly useful for
    /// CI/CD pipelines and different deployment environments.
    ///
    /// ## Supported Environment Variables:
    /// - `LIFEFORGE_API_BASE_URL`: Override base URL
    /// - `LIFEFORGE_REQUEST_TIMEOUT`: Override request timeout
    /// - `LIFEFORGE_ENABLE_LOGGING`: Enable/disable logging
    private func loadFromEnvironmentVariables() {
        if let envBaseURL = ProcessInfo.processInfo.environment["LIFEFORGE_API_BASE_URL"] {
            baseURL = envBaseURL
        }

        if let envTimeoutString = ProcessInfo.processInfo.environment["LIFEFORGE_REQUEST_TIMEOUT"],
           let envTimeout = TimeInterval(envTimeoutString) {
            requestTimeout = envTimeout
        }

        if let envLoggingString = ProcessInfo.processInfo.environment["LIFEFORGE_ENABLE_LOGGING"],
           let envLogging = Bool(envLoggingString) {
            isLoggingEnabled = envLogging
        }
    }

    /// Applies debug-specific configuration overrides
    ///
    /// In debug builds, certain settings may need to be different
    /// for development purposes (extended timeouts, enabled logging, etc.)
    private func applyDebugConfiguration() {
        #if DEBUG
            // Enable logging in debug builds
            isLoggingEnabled = true

            // Extend timeout for debugging scenarios
            requestTimeout = max(requestTimeout, 60.0)
        #endif
    }

    /// Validates that the base URL is a properly formatted URL
    ///
    /// Ensures the base URL contains a scheme (http/https) and a host.
    /// This prevents issues where only path components are provided.
    /// Supports localhost URLs for local development.
    ///
    /// - Parameter url: The URL string to validate
    /// - Returns: true if the URL is valid, false otherwise
    private func validateBaseURL(_ url: String) -> Bool {
        let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty else {
            return false
        }

        // Check if URL has a valid scheme (http:// or https://)
        guard trimmedURL.hasPrefix("http://") || trimmedURL.hasPrefix("https://") else {
            if trimmedURL.hasPrefix("http:") || trimmedURL.hasPrefix("https:") {
                OSLogger.error("NetworkConfiguration: URL appears truncated: '\(trimmedURL)'")
            }
            return false
        }

        // Use URLComponents for better parsing, especially for localhost with ports
        guard let urlComponents = URLComponents(string: trimmedURL),
              let scheme = urlComponents.scheme,
              scheme == "http" || scheme == "https",
              let host = urlComponents.host,
              !host.isEmpty else {
            return false
        }

        // Validate host: allow localhost, IP addresses, and domain names
        let ipPattern = "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$"
        let domainPattern = "^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?" +
            "(\\.[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?)*$"
        let isValidHost = host == "localhost" ||
            host.range(of: ipPattern, options: .regularExpression) != nil ||
            host.range(of: domainPattern, options: .regularExpression) != nil

        return isValidHost
    }

    // MARK: - Runtime Configuration Updates

    /// Updates the base URL at runtime
    ///
    /// This method allows changing the API base URL during app execution,
    /// which can be useful for:
    /// - Environment switching in debug builds
    /// - A/B testing different API endpoints
    /// - Fallback to alternative servers
    ///
    /// - Parameter newBaseURL: The new base URL to use for API requests
    ///
    /// ## Usage Example:
    /// ```swift
    /// // Switch to staging environment
    /// NetworkConfiguration.shared.updateBaseURL("https://staging-api.lifeforge.app")
    /// ```
    func updateBaseURL(_ newBaseURL: String) {
        baseURL = newBaseURL
    }

    /// Updates the request timeout at runtime
    ///
    /// Allows adjusting the network timeout based on runtime conditions
    /// such as network quality or specific API requirements.
    ///
    /// - Parameter newTimeout: The new timeout interval in seconds
    func updateRequestTimeout(_ newTimeout: TimeInterval) {
        requestTimeout = max(newTimeout, 5.0) // Minimum 5 seconds
    }

    /// Toggles network logging on or off
    ///
    /// Enables or disables network request/response logging, useful
    /// for debugging without requiring app restart.
    ///
    /// - Parameter enabled: Whether logging should be enabled
    func setLoggingEnabled(_ enabled: Bool) {
        isLoggingEnabled = enabled
    }
}
