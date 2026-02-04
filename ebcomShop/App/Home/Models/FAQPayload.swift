//
//  FAQPayload.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-04.
//

import Foundation

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
