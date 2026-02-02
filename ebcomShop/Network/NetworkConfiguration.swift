//
//  NetworkConfiguration.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation

/// Network configuration loaded from .xcconfig (via Info.plist).
/// Set NETWORK_BASE_URL, NETWORK_REQUEST_TIMEOUT, NETWORK_MAX_RETRY_ATTEMPTS, NETWORK_LOGGING_ENABLED in debug.xcconfig / release.xcconfig.
final class NetworkConfiguration {
    static let shared = NetworkConfiguration()

    private(set) var baseURL: String
    private(set) var requestTimeout: TimeInterval
    private(set) var maxRetryAttempts: Int
    private(set) var isLoggingEnabled: Bool

    private enum Default {
        static let baseURL = "http://185.204.197.213:5906"
        static let requestTimeout: TimeInterval = 30.0
        static let maxRetryAttempts = 3
        static let isLoggingEnabled = false
    }

    private init() {
        self.baseURL = Default.baseURL
        self.requestTimeout = Default.requestTimeout
        self.maxRetryAttempts = Default.maxRetryAttempts
        self.isLoggingEnabled = Default.isLoggingEnabled
        loadFromXCConfig()
    }

    private func loadFromXCConfig() {
        guard let info = Bundle.main.infoDictionary else {
            OSLogger.error("NetworkConfiguration: Failed to load Info.plist")
            return
        }

        if let url = (info[Constants.NetworkConfigKey.baseURL] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !url.isEmpty, validateBaseURL(url) {
            baseURL = url
        } else if let url = (info[Constants.NetworkConfigKey.apiBaseURL] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !url.isEmpty, validateBaseURL(url) {
            baseURL = url
        }

        if let s = info[Constants.NetworkConfigKey.requestTimeout] as? String, let t = Double(s) {
            requestTimeout = t
        }
        if let s = info[Constants.NetworkConfigKey.maxRetryAttempts] as? String, let n = Int(s) {
            maxRetryAttempts = n
        }
        if let s = info[Constants.NetworkConfigKey.loggingEnabled] as? String {
            isLoggingEnabled = s.lowercased() == "yes" || s.lowercased() == "true"
        }
    }

    private func validateBaseURL(_ url: String) -> Bool {
        guard let components = URLComponents(string: url),
              let scheme = components.scheme,
              (scheme == "http" || scheme == "https"),
              let host = components.host, !host.isEmpty else {
            return false
        }
        let ipPattern = "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$"
        let domainPattern = "^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?)*$"
        return host == "localhost"
            || host.range(of: ipPattern, options: .regularExpression) != nil
            || host.range(of: domainPattern, options: .regularExpression) != nil
    }
}
