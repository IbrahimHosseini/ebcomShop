//
//  CachedHomeResponse.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-06.
//

import Foundation
import SwiftData

@Model
final class CachedHomeResponse {
    /// Unique identifier (always "home" for single-cache pattern)
    @Attribute(.unique) var id: String
    
    /// JSON-encoded HomeResponse data
    var responseData: Data
    
    /// Last update timestamp
    var lastUpdated: Date
    
    init(id: String = "home", responseData: Data, lastUpdated: Date = Date()) {
        self.id = id
        self.responseData = responseData
        self.lastUpdated = lastUpdated
    }
}
