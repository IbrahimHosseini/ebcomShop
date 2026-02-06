//
//  HomeModels.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation

// MARK: - Home API Response

struct HomeResponse: Codable, Sendable {
    let home: HomePayload
    let categories: [CategoryModel]
    let shops: [ShopModel]
    let banners: [BannerModel]
    let tags: [TagModel]?
    let labels: [LabelModel]?
}

struct HomePayload: Codable, Sendable {
    let search: Bool?
    let faq: FAQPayload?
    let sections: [HomeSectionPayload]
}

struct HomeSectionPayload: Codable, Sendable {
    let title: String?
    let type: HomeSectionType
    let subType: String?
    let list: [String]
}

enum HomeSectionType: String, Codable, Sendable {
    case category = "CATEGORY"
    case banner = "BANNER"
    case shop = "SHOP"
    case fixedBanner = "FIXEDBANNER"
}
