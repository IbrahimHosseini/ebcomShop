//
//  BannerModel.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-04.
//

import Foundation

// MARK: - Banners

struct BannerModel: Codable, Sendable, Identifiable {
    let id: String
    let imageUrl: String
}
