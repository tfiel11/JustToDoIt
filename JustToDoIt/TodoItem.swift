import Foundation

// This is our data model for a to-do item
struct TodoItem: Identifiable, Codable {
    let id = UUID()      // A unique identifier for each item
    var title: String    // The text of the to-do item
    var isCompleted: Bool // Whether the item is checked off
} 