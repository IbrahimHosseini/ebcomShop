//
//  HomeRepository.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-06.
//

import Foundation
import SwiftData

@MainActor
final class HomeRepository: HomeRepositoryProtocol {
    private let modelContext: ModelContext
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchCached() -> HomeResponse? {
        let descriptor = FetchDescriptor<CachedHomeResponse>(
            predicate: #Predicate { $0.id == "home" }
        )
        
        guard let cached = try? modelContext.fetch(descriptor).first else {
            return nil
        }
        
        return try? decoder.decode(HomeResponse.self, from: cached.responseData)
    }
    
    func save(_ response: HomeResponse) throws {
        let responseData = try encoder.encode(response)
        
        // Fetch existing cache entry
        let descriptor = FetchDescriptor<CachedHomeResponse>(
            predicate: #Predicate { $0.id == "home" }
        )
        
        if let existing = try? modelContext.fetch(descriptor).first {
            // Update existing entry
            existing.responseData = responseData
            existing.lastUpdated = Date()
        } else {
            // Create new entry
            let cached = CachedHomeResponse(
                id: "home",
                responseData: responseData,
                lastUpdated: Date()
            )
            modelContext.insert(cached)
        }
        
        try modelContext.save()
    }
}
