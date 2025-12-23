//
//  ContentView.swift
//  CatFinderSwipe
//
//  Created by David on 22/12/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            SwipeDeckView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FavoriteCat.self, SeenCat.self], inMemory: true)
}
