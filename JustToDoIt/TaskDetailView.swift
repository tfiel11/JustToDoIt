import SwiftUI

struct TaskDetailView: View {
    // Environment object to access the shared todo store
    @EnvironmentObject var todoStore: TodoStore
    
    // Access to category store
    @EnvironmentObject var categoryStore: CategoryStore
    
    // The index of the item in the todoStore.items array
    let itemIndex: Int
    
    // State to track edited values
    @State private var editedTitle: String
    @State private var isCompleted: Bool
    @State private var notes: String
    @State private var selectedCategoryId: UUID?
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    
    // State to control showing the delete confirmation
    @State private var showingDeleteConfirmation = false
    
    // Environment value to dismiss this view
    @Environment(\.dismiss) private var dismiss
    
    // Initialize with values from the todo item
    init(itemIndex: Int, todoStore: TodoStore) {
        self.itemIndex = itemIndex
        let item = todoStore.items[itemIndex]
        
        self._editedTitle = State(initialValue: item.title)
        self._isCompleted = State(initialValue: item.isCompleted)
        self._notes = State(initialValue: item.notes)
        self._selectedCategoryId = State(initialValue: item.categoryId)
        self._hasDueDate = State(initialValue: item.dueDate != nil)
        self._dueDate = State(initialValue: item.dueDate ?? Date())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Task Details")) {
                TextField("Task title", text: $editedTitle)
                
                Toggle("Completed", isOn: $isCompleted)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(5)
            }
            
            Section(header: Text("Category")) {
                Picker("Category", selection: $selectedCategoryId) {
                    Text("None").tag(nil as UUID?)
                    ForEach(categoryStore.categories) { category in
                        HStack {
                            Circle()
                                .fill(category.color.color)
                                .frame(width: 12, height: 12)
                            Text(category.name)
                        }
                        .tag(category.id as UUID?)
                    }
                }
            }
            
            Section(header: Text("Due Date")) {
                Toggle("Has Due Date", isOn: $hasDueDate.animation())
                
                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
            }
            
            Section {
                Button(role: .destructive, action: {
                    showingDeleteConfirmation = true
                }) {
                    Label("Delete Task", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Edit Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    // Update the item in the store
                    todoStore.items[itemIndex].title = editedTitle
                    todoStore.items[itemIndex].isCompleted = isCompleted
                    todoStore.items[itemIndex].notes = notes
                    todoStore.items[itemIndex].categoryId = selectedCategoryId
                    todoStore.items[itemIndex].dueDate = hasDueDate ? dueDate : nil
                    
                    // Dismiss this view
                    dismiss()
                }
                .disabled(editedTitle.isEmpty)
            }
        }
        .alert("Delete Task", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Remove the item from the store
                todoStore.items.remove(at: itemIndex)
                // Dismiss this view
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this task? This cannot be undone.")
        }
    }
}

#Preview {
    // Create a sample TodoStore with test data
    let todoStore = TodoStore()
    todoStore.items = [
        TodoItem(title: "Sample Task", isCompleted: false, notes: "This is a sample task")
    ]
    
    // Create a sample CategoryStore
    let categoryStore = CategoryStore()
    
    // Return the preview with proper environment objects
    return NavigationStack {
        TaskDetailView(itemIndex: 0, todoStore: todoStore)
            .environmentObject(todoStore)
            .environmentObject(categoryStore)
    }
} 