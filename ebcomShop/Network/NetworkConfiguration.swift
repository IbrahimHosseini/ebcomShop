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
        guard let info = Bundle.main.infoDictionary
        else {
            OSLogger.error("NetworkConfiguration: Failed to load Info.plist")
            return
        }

        if let url = info.trimmedString(forKey: Constants.NetworkConfigKey.baseURL),
           !url.isEmpty,
           validateBaseURL(url) {
            baseURL = url
        }

        if let stringKey = info.string(forKey: Constants.NetworkConfigKey.requestTimeout),
           let timeout = Double(stringKey) {
            requestTimeout = timeout
        }
        
        if let stringKey = info.string(forKey: Constants.NetworkConfigKey.maxRetryAttempts),
           let retryAttempt = Int(stringKey) {
            maxRetryAttempts = retryAttempt
        }
        
        if let stringKey = info.string(forKey: Constants.NetworkConfigKey.loggingEnabled) {
            isLoggingEnabled = stringKey.lowercased() == "yes" || stringKey.lowercased() == "true"
        }
    }
    
}

extension NetworkConfiguration {
    private func validateBaseURL(_ url: String) -> Bool {
        guard let components = URLComponents(string: url),
              let scheme = components.scheme,
              (scheme == "http" || scheme == "https"),
              let host = components.host,
              !host.isEmpty
        else {
            return false
        }
        
        let ipPattern = "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$"
        let domainPattern = "^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?)*$"
        return host == "localhost"
        || host.range(of: ipPattern, options: .regularExpression) != nil
        || host.range(of: domainPattern, options: .regularExpression) != nil
    }
}
