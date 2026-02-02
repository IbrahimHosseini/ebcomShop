//
//  HomeEndpoint.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation

enum HomeEndpoint: APIEndpoint {
    case getHome

    var path: String {
        "/ebcom/shop.json"
    }
}
