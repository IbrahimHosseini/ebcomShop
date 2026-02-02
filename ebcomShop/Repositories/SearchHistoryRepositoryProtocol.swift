//
//  SearchHistoryRepositoryProtocol.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation

protocol SearchHistoryRepositoryProtocol {
    /// Returns search terms ordered by most recent first.
    func fetchTerms() -> [String]

    /// Adds a term (replacing any existing case-insensitive match) and trims to max count.
    func add(term: String) throws

    /// Deletes all entries whose term matches (case-insensitive).
    func delete(matching term: String) throws
}
