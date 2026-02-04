//
//  CategoryModel.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-04.
//

import Foundation

// MARK: - Categories

struct CategoryModel: Decodable, Sendable, Identifiable {
    let id: String
    let title: String
    let iconUrl: String
    let status: String?
}
