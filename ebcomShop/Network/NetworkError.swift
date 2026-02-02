//
//  defines.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

/// Network-related error cases for API operations
///
/// This enum defines all possible network errors that can occur during API requests.
/// Each case represents a specific failure scenario with a localized error description.
///
/// ## Error Cases:
/// - `invalidURL`: The provided URL is malformed or invalid
/// - `noData`: The server response contained no data
/// - `decodingFailed`: Failed to decode the response data into the expected model
/// - `badRequest`: The request was malformed or invalid (HTTP 4xx errors)
/// - `notFound`: The requested resource was not found (HTTP 404)
/// - `authorizationFailed`: Authentication or authorization failed (HTTP 401/403)
/// - `serverError`: Internal server error occurred (HTTP 5xx errors)
/// - `timeout`: The request timed out
/// - `noInternetConnection`: No internet connection available
enum NetworkError: LocalizedError, Sendable {
    case invalidURL
    case noData
    case decodingFailed
    case badRequest
    case notFound
    case authorizationFailed
    case serverError
    case timeout
    case noInternetConnection

    /// Human-readable error descriptions for debugging and user feedback
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "آدرس اینترنتی نامعتبر یا نادرست است"
        case .noData:
            "داده‌ای از سرور دریافت نشد"
        case .decodingFailed:
            "پردازش پاسخ سرور با خطا مواجه شد"
        case .badRequest:
            "درخواست نامعتبر یا نادرست است"
        case .notFound:
            "منبع درخواستی یافت نشد"
        case .authorizationFailed:
            "احراز هویت یا مجوز دسترسی با خطا مواجه شد"
        case .serverError:
            "خطای داخلی سرور رخ داده است"
        case .timeout:
            "زمان درخواست به پایان رسید"
        case .noInternetConnection:
            "اتصال اینترنت برقرار نیست"
        }
    }

    /// Error codes for programmatic handling
    var errorCode: Int {
        switch self {
        case .invalidURL:
            -1001
        case .noData:
            -1002
        case .decodingFailed:
            -1003
        case .badRequest:
            400
        case .notFound:
            404
        case .authorizationFailed:
            401
        case .serverError:
            500
        case .timeout:
            -1004
        case .noInternetConnection:
            -1005
        }
    }
}
