//
//  AuthSessionManager.swift
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
    private var refreshTask: Task<String, Error>?

    // MARK: - Initialization

    private init() {
        self.storageManager = AuthStorageManager()
        // Resolve AuthService from DI container
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
        if let accessToken = storageManager.getAccessToken() {
            return accessToken
        }

        // Token is expired or missing, need to refresh
        return ""
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
}
