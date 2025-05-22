//
//  JustToDoItApp.swift
//  JustToDoIt
//
//  Created by Tyler Fielding on 5/17/25.
//

import SwiftUI

@main
struct JustToDoItApp: App {
    // Create Core Data store
    @StateObject private var coreDataStore = CoreDataTodoStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coreDataStore)
                .onAppear {
                    // Set app appearance
                    UINavigationBar.appearance().tintColor = .systemBlue
                }
        }
    }
}
