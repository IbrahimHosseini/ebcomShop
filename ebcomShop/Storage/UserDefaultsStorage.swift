//
//  UserDefaultsStorage.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

// MARK: - UserDefaults Storage Implementation

/// A concrete implementation of LocalStorageProtocol using UserDefaults
final class UserDefaultsStorage: LocalStorageProtocol {
    private let defaults: UserDefaults
    private let suiteName: String?

    /// Initializes a new UserDefaults storage instance
    /// - Parameter suiteName: Optional suite name for shared UserDefaults
    init(suiteName: String? = nil) {
        self.suiteName = suiteName
        if let suiteName {
            self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
        } else {
            self.defaults = .standard
        }
    }

    func store(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    func store(_ data: Data, forKey key: String) {
        defaults.set(data, forKey: key)
        defaults.synchronize()
    }

    func getString(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    func getData(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }

    func removeAll() {
        // Remove all keys with our app prefix
        let dictionary = defaults.dictionaryRepresentation()
        for key in dictionary.keys where key.hasPrefix("lifeforge.") {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }

    func exists(forKey key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }
}
