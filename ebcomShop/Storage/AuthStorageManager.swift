//
//  AuthStorageManager.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

// MARK: - Auth Storage Manager

/// Manages authentication-related storage operations with support for multiple storage backends
final class AuthStorageManager {
    // MARK: - Storage Keys

    private enum StorageKey {
        static let accessToken = "lifeforge.accessToken"
        static let refreshToken = "lifeforge.refreshToken"
        static let userProfile = "lifeforge.userProfile"
        static let tokenExpiresAt = "lifeforge.tokenExpiresAt"
    }

    // MARK: - Properties

    private let storage: LocalStorageProtocol

    /// Current storage type being used
    let storageType: StorageType

    // MARK: - Initialization

    /// Initializes the auth storage manager with the specified storage type
    /// - Parameter storageType: The type of storage to use (default: .keychain)
    init(storageType: StorageType = .keychain) {
        self.storageType = storageType
        self.storage = StorageFactory.createStorage(type: storageType)
    }

    /// Initializes with a custom storage implementation
    /// - Parameter storage: A custom storage implementation
    init(storage: LocalStorageProtocol) {
        self.storage = storage
        self.storageType = .keychain // Default, may not be accurate for custom implementations
    }

    // MARK: - Token Management

    /// Stores authentication tokens
    /// - Parameters:
    ///   - accessToken: The access token
    ///   - refreshToken: The refresh token
    func storeTokens(accessToken: String, refreshToken: String) {
        storage.store(accessToken, forKey: StorageKey.accessToken)
        storage.store(refreshToken, forKey: StorageKey.refreshToken)
        OSLogger.info("Tokens stored successfully using \(storageType)")
    }

    /// Stores authentication tokens with expiry information
    /// - Parameters:
    ///   - accessToken: The access token
    ///   - refreshToken: The refresh token
    ///   - expiresIn: Token expiry time in seconds from now
    func storeTokens(accessToken: String, refreshToken: String, expiresIn: Int) {
        storeTokens(accessToken: accessToken, refreshToken: refreshToken)
        
        // Calculate expiry timestamp (5-minute buffer for proactive refresh)
        let expiryDate = Date().addingTimeInterval(TimeInterval(expiresIn - 300))
        let expiryTimestamp = expiryDate.timeIntervalSince1970
        storage.store(String(expiryTimestamp), forKey: StorageKey.tokenExpiresAt)
        
        OSLogger.info("Tokens stored successfully with expiry using \(storageType)")
    }

    /// Retrieves the stored access token
    /// - Returns: The access token, or nil if not found
    func getAccessToken() -> String? {
        storage.getString(forKey: StorageKey.accessToken)
    }

    /// Retrieves the stored refresh token
    /// - Returns: The refresh token, or nil if not found
    func getRefreshToken() -> String? {
        storage.getString(forKey: StorageKey.refreshToken)
    }

    /// Checks if valid tokens exist
    /// - Returns: True if both access and refresh tokens exist
    func hasValidTokens() -> Bool {
        getAccessToken() != nil && getRefreshToken() != nil
    }

    /// Checks if the access token is expired or about to expire
    /// Uses a 5-minute buffer to allow proactive refresh
    /// - Returns: True if token is expired or will expire within 5 minutes
    func isAccessTokenExpired() -> Bool {
        guard let expiresAtString = storage.getString(forKey: StorageKey.tokenExpiresAt),
              let expiresAtTimestamp = TimeInterval(expiresAtString)
        else {
            // If no expiry stored, assume expired to force refresh
            return true
        }
        
        let expiryDate = Date(timeIntervalSince1970: expiresAtTimestamp)
        return Date() >= expiryDate
    }

    // MARK: - User Data Management

    /// Stores user profile data
    /// - Parameter user: The user to store
    func storeUser(_ user: User) {
        guard let userData = try? JSONEncoder().encode(user) else {
            OSLogger.error("Failed to encode user data")
            return
        }
        storage.store(userData, forKey: StorageKey.userProfile)
        OSLogger.info("User profile stored successfully")
    }

    /// Retrieves the stored user profile
    /// - Returns: The user profile, or nil if not found or unable to decode
    func getUser() -> User? {
        guard let userData = storage.getData(forKey: StorageKey.userProfile) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(User.self, from: userData)
        } catch {
            OSLogger.error("Failed to decode user data: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Session Management

    /// Clears all authentication data
    func clearSession() {
        storage.remove(forKey: StorageKey.accessToken)
        storage.remove(forKey: StorageKey.refreshToken)
        storage.remove(forKey: StorageKey.userProfile)
        storage.remove(forKey: StorageKey.tokenExpiresAt)
        
        // Also clear legacy UserDefaults keys (migration cleanup)
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "lifeforge.accessToken")
        defaults.removeObject(forKey: "lifeforge.refreshToken")
        defaults.removeObject(forKey: "lifeforge.userProfile")
        defaults.removeObject(forKey: "lifeforge.appleUserIdentifier")
        defaults.synchronize()
        
        OSLogger.info("Session cleared successfully")
    }

    /// Checks if user is authenticated
    /// - Returns: True if valid tokens exist
    func isAuthenticated() -> Bool {
        hasValidTokens()
    }

    /// Migrates data from one storage type to another
    /// - Parameter targetType: The target storage type to migrate to
    func migrateStorage(to targetType: StorageType) {
        guard targetType != storageType else {
            OSLogger.warning("Target storage type is the same as current, no migration needed")
            return
        }

        // Create target storage
        let targetStorage = StorageFactory.createStorage(type: targetType)

        // Migrate tokens
        if let accessToken = getAccessToken() {
            targetStorage.store(accessToken, forKey: StorageKey.accessToken)
        }

        if let refreshToken = getRefreshToken() {
            targetStorage.store(refreshToken, forKey: StorageKey.refreshToken)
        }

        // Migrate user data
        if let userData = storage.getData(forKey: StorageKey.userProfile) {
            targetStorage.store(userData, forKey: StorageKey.userProfile)
        }

        // Clear old storage
        clearSession()

        OSLogger.info("Successfully migrated from \(storageType) to \(targetType)")
    }
}
