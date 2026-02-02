import Foundation
import Security

// MARK: - Keychain Storage Implementation

/// A concrete implementation of LocalStorageProtocol using Keychain
final class KeychainStorage: LocalStorageProtocol {
    private let service: String
    private let accessGroup: String?

    /// Initializes a new Keychain storage instance
    /// - Parameters:
    ///   - service: The service name for Keychain items (default: app bundle identifier)
    ///   - accessGroup: Optional access group for shared Keychain access
    init(service: String = "com.lifeforge.auth", accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    func store(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else {
            OSLogger.error("Failed to convert string to data for key: \(key)")
            return
        }
        store(data, forKey: key)
    }

    func store(_ data: Data, forKey key: String) {
        var query = baseQuery(forKey: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            OSLogger.error("Failed to store data in Keychain for key '\(key)': \(status)")
        }
    }

    func getString(forKey key: String) -> String? {
        guard let data = getData(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func getData(forKey key: String) -> Data? {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            return data
        }

        return nil
    }

    func remove(forKey key: String) {
        let query = baseQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess, status != errSecItemNotFound {
            OSLogger.error("Failed to remove Keychain item for key '\(key)': \(status)")
        }
    }

    func removeAll() {
        // Remove all items for this service
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess, status != errSecItemNotFound {
            OSLogger.error("Failed to clear all Keychain items: \(status)")
        }
    }

    func exists(forKey key: String) -> Bool {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = false

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Private Helpers

    private func baseQuery(forKey key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        return query
    }
}
