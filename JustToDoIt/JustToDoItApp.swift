//
//  JustToDoItApp.swift
//  JustToDoIt
//
//  Created by Tyler Fielding on 5/17/25.
//

import SwiftUI

@main
struct JustToDoItApp: App {
    // Create a shared TodoStore instance
    @StateObject private var todoStore = TodoStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoStore)
        }
    }
}
