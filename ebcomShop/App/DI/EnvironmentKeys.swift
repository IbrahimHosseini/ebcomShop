//
//  EnvironmentKeys.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI

// MARK: - HomeService

private struct HomeServiceKey: EnvironmentKey {
    static let defaultValue: HomeServiceProtocol = HomeServiceImpl()
}

extension EnvironmentValues {
    var homeService: HomeServiceProtocol {
        get { self[HomeServiceKey.self] }
        set { self[HomeServiceKey.self] = newValue }
    }
}
