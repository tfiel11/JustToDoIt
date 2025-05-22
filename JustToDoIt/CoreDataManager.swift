import Foundation
import CoreData
import SwiftUI

class CoreDataManager {
    // Shared instance for easy access throughout the app
    static let shared = CoreDataManager()
    
    // Core Data container
    let container: NSPersistentContainer
    
    // Context for main thread operations
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // Private initializer for singleton pattern
    private init() {
        container = NSPersistentContainer(name: "TodoModel")
        
        // Load the persistent stores
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error.localizedDescription)")
            }
            
            // Enable automatic merging of changes from parent contexts
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            
            // Configure merge policy to handle conflicts
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            // Create default categories if none exist
            self.createDefaultCategoriesIfNeeded()
        }
    }
    
    // Save changes if there are any
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Handle the Core Data error
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Create default categories if none exist
    private func createDefaultCategoriesIfNeeded() {
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        
        do {
            let count = try viewContext.count(for: fetchRequest)
            
            if count == 0 {
                // Create default categories
                _ = createCategory(name: "Work", colorName: "blue")
                _ = createCategory(name: "Personal", colorName: "green")
                _ = createCategory(name: "Shopping", colorName: "orange")
                _ = createCategory(name: "Urgent", colorName: "red")
                
                // Add some sample tasks
                let workCategory = fetchAllCategories().first { $0.name == "Work" }
                let personalCategory = fetchAllCategories().first { $0.name == "Personal" }
                
                _ = createTodoItem(
                    title: "Complete project proposal",
                    notes: "Include budget and timeline",
                    category: workCategory
                )
                
                _ = createTodoItem(
                    title: "Schedule dentist appointment",
                    category: personalCategory
                )
                
                _ = createTodoItem(
                    title: "Learn Core Data",
                    notes: "Great for complex data relationships",
                    category: workCategory
                )
                
                saveContext()
            }
        } catch {
            print("Error checking for categories: \(error)")
        }
    }
    
    // MARK: - Todo Item Operations
    
    // Create a new todo item
    func createTodoItem(title: String, isCompleted: Bool = false, notes: String = "", dueDate: Date? = nil, category: CategoryEntity? = nil) -> TodoItemEntity {
        let newItem = TodoItemEntity(context: viewContext)
        newItem.id = UUID()
        newItem.title = title
        newItem.isCompleted = isCompleted
        newItem.notes = notes
        newItem.dueDate = dueDate
        newItem.category = category
        saveContext()
        return newItem
    }
    
    // Delete a todo item
    func deleteTodoItem(_ item: TodoItemEntity) {
        viewContext.delete(item)
        saveContext()
    }
    
    // Fetch all todo items
    func fetchAllTodoItems() -> [TodoItemEntity] {
        let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        
        // Sort by completion status and then by title
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TodoItemEntity.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \TodoItemEntity.title, ascending: true)
        ]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching todo items: \(error)")
            return []
        }
    }
    
    // MARK: - Category Operations
    
    // Create a new category
    func createCategory(name: String, colorName: String) -> CategoryEntity {
        let newCategory = CategoryEntity(context: viewContext)
        newCategory.id = UUID()
        newCategory.name = name
        newCategory.colorName = colorName
        saveContext()
        return newCategory
    }
    
    // Delete a category
    func deleteCategory(_ category: CategoryEntity) {
        viewContext.delete(category)
        saveContext()
    }
    
    // Fetch all categories
    func fetchAllCategories() -> [CategoryEntity] {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
} 