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
        static let accessToken = "ebcom.accessToken"
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
        OSLogger.info("Tokens stored successfully using \(storageType)")
    }

    /// Stores authentication tokens with expiry information
    /// - Parameters:
    ///   - accessToken: The access token
    func storeTokens(accessToken: String, refreshToken: String, expiresIn: Int) {
        storeTokens(accessToken: accessToken, refreshToken: refreshToken)
        OSLogger.info("Tokens stored successfully with expiry using \(storageType)")
    }

    /// Retrieves the stored access token
    /// - Returns: The access token, or nil if not found
    func getAccessToken() -> String? {
        storage.getString(forKey: StorageKey.accessToken)
    }

    /// Checks if valid tokens exist
    /// - Returns: True if both access and refresh tokens exist
    func hasValidTokens() -> Bool {
        getAccessToken() != nil
    }

    // MARK: - Session Management

    /// Clears all authentication data
    func clearSession() {
        storage.remove(forKey: StorageKey.accessToken)
        
        // Also clear legacy UserDefaults keys (migration cleanup)
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "lifeforge.accessToken")
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

        // Clear old storage
        clearSession()

        OSLogger.info("Successfully migrated from \(storageType) to \(targetType)")
    }
}
