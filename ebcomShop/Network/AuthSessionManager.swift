//
//  ensures.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

// MARK: - Session Expiry Notification

extension Notification.Name {
    static let userSessionExpired = Notification.Name("lifeforge.userSessionExpired")
    static let iCloudSyncSettingChanged = Notification.Name("lifeforge.iCloudSyncSettingChanged")
}

// MARK: - Auth Session Manager

/// Centralized, thread-safe manager for authentication token lifecycle
///
/// This actor ensures that:
/// - Only one token refresh happens at a time
/// - Tokens are automatically refreshed before expiry
/// - Session expiry is properly handled and broadcast
///
/// ## Usage:
/// ```swift
/// let token = try await AuthSessionManager.shared.getValidAccessToken()
/// ```
actor AuthSessionManager {
    static let shared = AuthSessionManager()

    // MARK: - Properties

    private let storageManager: AuthStorageManager
    private let authService: AuthServiceProtocol
    private var refreshTask: Task<String, Error>?

    // MARK: - Initialization

    private init() {
        self.storageManager = AuthStorageManager()
        // Resolve AuthService from DI container
        self.authService = DIContainer.shared.resolve(AuthServiceProtocol.self)
    }

    // MARK: - Public Methods

    /// Gets a valid access token, refreshing if necessary
    ///
    /// This method:
    /// 1. Checks if current token is expired
    /// 2. If expired, attempts to refresh using refresh token
    /// 3. Returns the valid access token
    ///
    /// - Returns: A valid access token
    /// - Throws: NetworkError if refresh fails or no tokens available
    func getValidAccessToken() async throws -> String {
        // Check if we have a valid, non-expired token
        if let accessToken = storageManager.getAccessToken(),
           !storageManager.isAccessTokenExpired() {
            return accessToken
        }

        // Token is expired or missing, need to refresh
        return try await refreshAccessToken()
    }

    /// Handles unauthorized responses (401/403)
    ///
    /// This method:
    /// 1. Clears the current session
    /// 2. Posts a notification to trigger logout in the app
    ///
    /// Should be called when any API returns 401/403
    func handleUnauthorized() {
        OSLogger.warning("Handling unauthorized response - clearing session")
        storageManager.clearSession()
        
        // Post notification on main thread
        Task { @MainActor in
            NotificationCenter.default.post(name: .userSessionExpired, object: nil)
        }
    }

    // MARK: - Private Methods

    /// Refreshes the access token using the refresh token
    ///
    /// Uses a task to ensure only one refresh happens at a time,
    /// even if multiple requests call this simultaneously.
    ///
    /// - Returns: The new access token
    /// - Throws: NetworkError if refresh fails
    private func refreshAccessToken() async throws -> String {
        // If a refresh is already in progress, wait for it
        if let existingTask = refreshTask {
            return try await existingTask.value
        }

        // Check if we have a refresh token
        guard let refreshToken = storageManager.getRefreshToken() else {
            OSLogger.error("No refresh token available for refresh")
            handleUnauthorized()
            throw NetworkError.authorizationFailed
        }

        // Create new refresh task
        let task = Task<String, Error> {
            do {
                let request = RefreshTokenRequest(refreshToken: refreshToken)
                let result = await authService.refreshToken(request)

                switch result {
                case .success(let response):
                    // Store new tokens with expiry
                    storageManager.storeTokens(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken,
                        expiresIn: response.expiresIn
                    )
                    OSLogger.info("Token refreshed successfully")
                    return response.accessToken

                case .failure(let error):
                    OSLogger.error("Token refresh failed: \(error.localizedDescription)")
                    handleUnauthorized()
                    throw error
                }
            } catch {
                OSLogger.error("Token refresh error: \(error.localizedDescription)")
                handleUnauthorized()
                throw error
            }
        }

        refreshTask = task

        do {
            let token = try await task.value
            refreshTask = nil
            return token
        } catch {
            refreshTask = nil
            throw error
        }
    }
}
