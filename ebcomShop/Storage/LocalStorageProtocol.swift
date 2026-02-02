//
//  LocalStorageProtocol.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

// MARK: - Local Storage Protocol

/// A protocol defining the interface for local data storage implementations.
/// Conforming types can store, retrieve, and delete data using different mechanisms
/// such as UserDefaults or Keychain.
protocol LocalStorageProtocol {
    /// Stores a string value for the given key
    /// - Parameters:
    ///   - value: The string value to store
    ///   - key: The key to associate with the value
    func store(_ value: String, forKey key: String)

    /// Stores data for the given key
    /// - Parameters:
    ///   - data: The data to store
    ///   - key: The key to associate with the data
    func store(_ data: Data, forKey key: String)

    /// Retrieves a string value for the given key
    /// - Parameter key: The key associated with the value
    /// - Returns: The stored string value, or nil if not found
    func getString(forKey key: String) -> String?

    /// Retrieves data for the given key
    /// - Parameter key: The key associated with the data
    /// - Returns: The stored data, or nil if not found
    func getData(forKey key: String) -> Data?

    /// Removes the value associated with the given key
    /// - Parameter key: The key to remove
    func remove(forKey key: String)

    /// Removes all stored values
    func removeAll()

    /// Checks if a value exists for the given key
    /// - Parameter key: The key to check
    /// - Returns: True if a value exists, false otherwise
    func exists(forKey key: String) -> Bool
}

// MARK: - Storage Configuration

/// Configuration for choosing storage mechanism
enum StorageType {
    case userDefaults
    case keychain
}

/// Factory for creating storage implementations
enum StorageFactory {
    /// Creates a storage implementation based on the specified type
    /// - Parameter type: The type of storage to create
    /// - Returns: A concrete implementation of LocalStorageProtocol
    static func createStorage(type: StorageType) -> LocalStorageProtocol {
        switch type {
        case .userDefaults:
            UserDefaultsStorage()
        case .keychain:
            KeychainStorage()
        }
    }
}
