//
//  EnvironmentKeys.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI
import SwiftData

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

// MARK: - HomeRepository

private struct HomeRepositoryKey: EnvironmentKey {
    static let defaultValue: HomeRepositoryProtocol? = nil
}

extension EnvironmentValues {
    var homeRepository: HomeRepositoryProtocol? {
        get { self[HomeRepositoryKey.self] }
        set { self[HomeRepositoryKey.self] = newValue }
    }
}

// MARK: - NetworkMonitor

private struct NetworkMonitorKey: EnvironmentKey {
    static let defaultValue: (any NetworkConnectivityProviding)? = nil
}

extension EnvironmentValues {
    var networkMonitor: (any NetworkConnectivityProviding)? {
        get { self[NetworkMonitorKey.self] }
        set { self[NetworkMonitorKey.self] = newValue }
    }
}
