import Foundation
import SwiftUI
import CoreData

// MARK: - Extensions for CategoryEntity

extension CategoryEntity {
    // Define color options directly in the extension
    enum CategoryColor: String, CaseIterable {
        case red, orange, yellow, green, blue, purple, gray
        
        var color: Color {
            switch self {
            case .red: return .red
            case .orange: return .orange
            case .yellow: return .yellow
            case .green: return .green
            case .blue: return .blue
            case .purple: return .purple
            case .gray: return .gray
            }
        }
    }
    
    // Get the SwiftUI Color for this category
    var color: Color {
        if let colorName = self.colorName,
           let categoryColor = CategoryColor(rawValue: colorName) {
            return categoryColor.color
        }
        return .blue // Default color
    }
}

// MARK: - NSPredicate Extensions

extension NSPredicate {
    // Create a predicate for filtering by category
    static func category(_ category: CategoryEntity?) -> NSPredicate {
        if let category = category {
            return NSPredicate(format: "category == %@", category)
        } else {
            return NSPredicate(format: "category == nil")
        }
    }
    
    // Create a predicate for filtering by completion status
    static func completed(_ isCompleted: Bool) -> NSPredicate {
        return NSPredicate(format: "isCompleted == %@", NSNumber(value: isCompleted))
    }
    
    // Create a predicate for searching by title
    static func titleContains(_ searchText: String) -> NSPredicate {
        return NSPredicate(format: "title CONTAINS[cd] %@", searchText)
    }
}
