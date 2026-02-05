//
//  SearchHistoryEntry.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation
import SwiftData

@Model
final class SearchHistoryEntry {
    var term: String
    var createdAt: Date

    init(term: String, createdAt: Date = Date()) {
        self.term = term
        self.createdAt = createdAt
    }
}
