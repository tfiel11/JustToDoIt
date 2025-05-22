import Foundation
import CoreData
import SwiftUI
import Combine

class CoreDataTodoStore: ObservableObject {
    // Published properties that will notify views when they change
    @Published var todoItems: [TodoItemEntity] = []
    @Published var categories: [CategoryEntity] = []
    
    // Core Data manager
    private let coreDataManager = CoreDataManager.shared
    
    // Cancellables for observation
    private var cancellables = Set<AnyCancellable>()
    
    // Initialize and load data
    init() {
        fetchAllData()
        
        // Set up notification observers for Core Data changes
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: coreDataManager.viewContext)
            .sink { [weak self] _ in
                self?.fetchAllData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Fetching
    
    func fetchAllData() {
        fetchTodoItems()
        fetchCategories()
    }
    
    func fetchTodoItems() {
        todoItems = coreDataManager.fetchAllTodoItems()
    }
    
    func fetchCategories() {
        categories = coreDataManager.fetchAllCategories()
    }
    
    // MARK: - Todo Item Operations
    
    func addTodoItem(title: String, isCompleted: Bool = false, notes: String = "", dueDate: Date? = nil, category: CategoryEntity? = nil) {
        _ = coreDataManager.createTodoItem(
            title: title,
            isCompleted: isCompleted,
            notes: notes,
            dueDate: dueDate,
            category: category
        )
        fetchTodoItems()
    }
    
    func updateTodoItem(_ item: TodoItemEntity, title: String? = nil, isCompleted: Bool? = nil, notes: String? = nil, dueDate: Date? = nil, category: CategoryEntity? = nil) {
        // Update only the fields that are provided
        if let title = title {
            item.title = title
        }
        
        if let isCompleted = isCompleted {
            item.isCompleted = isCompleted
        }
        
        if let notes = notes {
            item.notes = notes
        }
        
        if let dueDate = dueDate {
            item.dueDate = dueDate
        }
        
        if let category = category {
            item.category = category
        }
        
        coreDataManager.saveContext()
        fetchTodoItems()
    }
    
    func toggleCompletion(for item: TodoItemEntity) {
        item.isCompleted.toggle()
        coreDataManager.saveContext()
        fetchTodoItems()
    }
    
    func deleteTodoItem(_ item: TodoItemEntity) {
        coreDataManager.deleteTodoItem(item)
        fetchTodoItems()
    }
    
    // MARK: - Category Operations
    
    func addCategory(name: String, colorName: String) {
        _ = coreDataManager.createCategory(name: name, colorName: colorName)
        fetchCategories()
    }
    
    func updateCategory(_ category: CategoryEntity, name: String? = nil, colorName: String? = nil) {
        if let name = name {
            category.name = name
        }
        
        if let colorName = colorName {
            category.colorName = colorName
        }
        
        coreDataManager.saveContext()
        fetchCategories()
    }
    
    func deleteCategory(_ category: CategoryEntity) {
        coreDataManager.deleteCategory(category)
        fetchCategories()
    }
    
    // MARK: - Helper Methods
    
    // Get todos for a specific category
    func todos(for category: CategoryEntity) -> [TodoItemEntity] {
        return todoItems.filter { $0.category == category }
    }
    
    // Get todos with no category
    var uncategorizedTodos: [TodoItemEntity] {
        return todoItems.filter { $0.category == nil }
    }
} 