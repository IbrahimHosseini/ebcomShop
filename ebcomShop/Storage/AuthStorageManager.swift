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

    /// Retrieves the stored access token
    /// - Returns: The access token, or nil if not found
    func getAccessToken() -> String? {
        storage.getString(forKey: StorageKey.accessToken)
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
}
