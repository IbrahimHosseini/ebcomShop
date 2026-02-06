//
//  TagModel.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-04.
//

import Foundation

// MARK: - Tags & Labels (minimal for display)

struct TagModel: Codable, Sendable, Identifiable {
    let id: String
    let title: String?
    let iconUrl: String?
    let status: String?
}

struct LabelModel: Codable, Sendable, Identifiable {
    let id: String
    let title: String?
    let status: String?
}
