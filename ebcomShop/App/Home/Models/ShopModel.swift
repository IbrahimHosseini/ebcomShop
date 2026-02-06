//
//  ShopModel.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-04.
//

import Foundation

// MARK: - Shops

struct ShopModel: Codable, Sendable, Identifiable {
    let id: String
    let title: String
    let iconUrl: String
    let labels: [String]?
    let tags: [String]?
    let categories: [String]?
    let about: ShopAbout?
    let type: [String]?
    let code: String?
    let status: String?
}

struct ShopAbout: Codable, Sendable {
    let title: String?
    let description: String?
}
