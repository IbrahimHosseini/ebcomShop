//
//  ebcomShopApp.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-02.
//

import SwiftUI
import SwiftData

@main
struct ebcomShopApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SearchHistoryEntry.self,
            CachedHomeResponse.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var networkMonitor = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.homeService, HomeServiceImpl())
                .environment(\.homeRepository, HomeRepository(modelContext: sharedModelContainer.mainContext))
                .environment(\.networkMonitor, networkMonitor)
        }
        .modelContainer(sharedModelContainer)
    }
}
