//
//  HomeEndpoint.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation

enum HomeEndpoint: APIEndpoint {
    case getHome

    var baseURL: String {
        "http://185.204.197.213:5906"
    }

    var path: String {
        "/ebcom/shop.json"
    }

    var requiresAuthentication: Bool {
        false
    }
}
