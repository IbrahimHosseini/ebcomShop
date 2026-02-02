//
//  Constants.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

typealias ResponseResult<T> = Result<T, NetworkError>

enum Constants {

    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// Info.plist keys for network configuration (from .xcconfig)
    enum NetworkConfigKey {
        static let baseURL = "API_BASE_URL"
        static let requestTimeout = "NETWORK_REQUEST_TIMEOUT"
        static let maxRetryAttempts = "NETWORK_MAX_RETRY_ATTEMPTS"
        static let loggingEnabled = "NETWORK_LOGGING_ENABLED"
    }
}
