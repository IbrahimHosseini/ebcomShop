//
//  HomeModels.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation

// MARK: - Home API Response

struct HomeResponse: Decodable, Sendable {
    let home: HomePayload
    let categories: [CategoryModel]
    let shops: [ShopModel]
    let banners: [BannerModel]
    let tags: [TagModel]?
    let labels: [LabelModel]?
}

struct HomePayload: Decodable, Sendable {
    let search: Bool?
    let faq: FAQPayload?
    let sections: [HomeSectionPayload]
}

struct HomeSectionPayload: Decodable, Sendable {
    let title: String?
    let type: HomeSectionType
    let subType: String?
    let list: [String]
}

enum HomeSectionType: String, Decodable, Sendable {
    case category = "CATEGORY"
    case banner = "BANNER"
    case shop = "SHOP"
    case fixedBanner = "FIXEDBANNER"
}

// MARK: - FAQ

struct FAQPayload: Decodable, Sendable {
    let id: String
    let title: String
    let sections: [FAQSectionItem]
}

struct FAQSectionItem: Decodable, Sendable {
    let title: String
    let description: String
}

// MARK: - Categories

struct CategoryModel: Decodable, Sendable, Identifiable {
    let id: String
    let title: String
    let iconUrl: String
    let status: String?
}

// MARK: - Shops

struct ShopModel: Decodable, Sendable, Identifiable {
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

struct ShopAbout: Decodable, Sendable {
    let title: String?
    let description: String?
}

// MARK: - Banners

struct BannerModel: Decodable, Sendable, Identifiable {
    let id: String
    let imageUrl: String
}

// MARK: - Tags & Labels (minimal for display)

struct TagModel: Decodable, Sendable, Identifiable {
    let id: String
    let title: String?
    let iconUrl: String?
    let status: String?
}

struct LabelModel: Decodable, Sendable, Identifiable {
    let id: String
    let title: String?
    let status: String?
}

// MARK: - View-ready section items (order preserved from API)

enum HomeSectionItem: Sendable {
    case category(title: String?, items: [CategoryModel])
    case banner(items: [BannerModel])
    case shop(title: String?, items: [ShopModel])
    case fixedBanner(title: String?, items: [BannerModel])
}
