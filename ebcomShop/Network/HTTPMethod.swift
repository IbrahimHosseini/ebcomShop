//
//  HTTPMethod.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//


import Foundation

/// HTTP method definitions for network requests
///
/// Defines the standard HTTP methods used in REST API communications.
/// Each case represents a different type of HTTP operation:
/// - GET: Retrieve data from the server
/// - POST: Send data to create new resources
/// - PUT: Send data to update existing resources (full update)
/// - PATCH: Send data to partially update existing resources
/// - DELETE: Remove resources from the server
enum HTTPMethod: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
