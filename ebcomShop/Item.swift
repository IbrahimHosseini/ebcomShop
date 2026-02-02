//
//  Item.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
