import Foundation
import SwiftUI

// This class manages storing and retrieving to-do items
class TodoStore: ObservableObject {
    // Published property that notifies views when it changes
    @Published var items: [TodoItem] = [] {
        didSet {
            // Save items whenever the array changes
            saveTodoItems()
        }
    }
    
    // Key for storing items in UserDefaults
    private let itemsKey = "todoItems"
    
    init() {
        // Load saved items when the store is created
        loadTodoItems()
    }
    
    // Save items to UserDefaults
    private func saveTodoItems() {
        if let encodedData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encodedData, forKey: itemsKey)
        }
    }
    
    // Load items from UserDefaults
    private func loadTodoItems() {
        if let savedItems = UserDefaults.standard.data(forKey: itemsKey),
           let decodedItems = try? JSONDecoder().decode([TodoItem].self, from: savedItems) {
            items = decodedItems
        }
    }
} 