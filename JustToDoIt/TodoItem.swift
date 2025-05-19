import Foundation

// This is our data model for a to-do item
struct TodoItem: Identifiable, Codable {
    let id = UUID()      // A unique identifier for each item
    var title: String    // The text of the to-do item
    var isCompleted: Bool // Whether the item is checked off
    var categoryId: UUID? // Optional reference to a category
    var notes: String = "" // Optional notes for the task
    var dueDate: Date? // Optional due date
}