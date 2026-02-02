//
//  HomeServiceImpl.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import Foundation

final class HomeServiceImpl: HomeServiceProtocol, Sendable {
    private let client: NetworkClient<HomeEndpoint>

    init(client: NetworkClient<HomeEndpoint> = NetworkClient<HomeEndpoint>()) {
        self.client = client
    }

    func fetchHome() async -> ResponseResult<HomeResponse> {
        await client.request(.getHome)
    }
}
