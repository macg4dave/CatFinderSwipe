//
//  CatFinderSwipeApp.swift
//  CatFinderSwipe
//
//  Created by David on 22/12/2025.
//

import SwiftUI
import SwiftData

@main
struct CatFinderSwipeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoriteCat.self,
            SeenCat.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
