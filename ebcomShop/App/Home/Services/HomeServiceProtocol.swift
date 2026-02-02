//
//  HomeServiceProtocol.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation

/// Protocol for the Home API service. Use this in ViewModels and inject via DI.
protocol HomeServiceProtocol: Sendable {
    func fetchHome() async -> ResponseResult<HomeResponse>
}
