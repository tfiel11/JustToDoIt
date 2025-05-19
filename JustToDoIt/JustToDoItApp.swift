//
//  JustToDoItApp.swift
//  JustToDoIt
//
//  Created by Tyler Fielding on 5/17/25.
//

import SwiftUI

@main
struct JustToDoItApp: App {
    // Create shared store instances
    @StateObject private var todoStore = TodoStore()
    @StateObject private var categoryStore = CategoryStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoStore)
                .environmentObject(categoryStore)
        }
    }
}
