//
//  Dictionary+Extension.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

// MARK: - String value by key

extension Dictionary where Key == String {
    /// Returns the value for `key` as a String, trimmed of whitespace and newlines, or nil.
    func trimmedString(forKey key: String) -> String? {
        (self[key] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns the value for `key` as a String, or nil.
    func string(forKey key: String) -> String? {
        self[key] as? String
    }
}

// MARK: - JSON serialization

/// Extensions for Dictionary to support JSON serialization
public extension Dictionary {
    /// Converts the dictionary to JSON data
    ///
    /// This computed property serializes the dictionary into JSON data format
    /// using `JSONSerialization` with pretty printing for better readability.
    ///
    /// - Returns: Optional `Data` object containing the JSON representation,
    ///           or `nil` if serialization fails
    ///
    /// ## Usage Example:
    /// ```swift
    /// let params = ["name": "John", "age": 30]
    /// if let jsonData = params.jsonData {
    ///     // Use the JSON data for network requests
    /// }
    /// ```
    var jsonData: Data? {
        try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
    }

    /// Converts the dictionary to a JSON string
    ///
    /// This method first converts the dictionary to JSON data, then creates
    /// a UTF-8 encoded string representation of that data.
    ///
    /// - Returns: Optional `String` containing the JSON representation,
    ///           or `nil` if conversion fails
    ///
    /// ## Usage Example:
    /// ```swift
    /// let params = ["name": "John", "age": 30]
    /// if let jsonString = params.toJSONString() {
    ///     print("JSON: \(jsonString)")
    /// }
    /// ```
    func toJSONString() -> String? {
        if let jsonData {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}

extension Encodable {
    var asDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }

        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else { return nil }

        return json
    }
}
