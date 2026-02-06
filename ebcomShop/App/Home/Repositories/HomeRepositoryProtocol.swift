//
//  HomeRepositoryProtocol.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-06.
//

import Foundation

protocol HomeRepositoryProtocol: Sendable {
    /// Fetches the cached home response from local storage
    /// - Returns: The cached HomeResponse if available, nil otherwise
    func fetchCached() -> HomeResponse?
    
    /// Saves a home response to local storage
    /// - Parameter response: The HomeResponse to cache
    /// - Throws: An error if the save operation fails
    func save(_ response: HomeResponse) throws
}
