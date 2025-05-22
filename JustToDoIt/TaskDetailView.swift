import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject private var coreDataStore: CoreDataTodoStore
    @Environment(\.dismiss) private var dismiss
    
    let task: TodoItemEntity
    
    @State private var title: String
    @State private var notes: String
    @State private var isCompleted: Bool
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var selectedCategory: CategoryEntity?
    
    init(task: TodoItemEntity) {
        self.task = task
        
        // Initialize state from task
        _title = State(initialValue: task.title ?? "")
        _notes = State(initialValue: task.notes ?? "")
        _isCompleted = State(initialValue: task.isCompleted)
        _hasDueDate = State(initialValue: task.dueDate != nil)
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _selectedCategory = State(initialValue: task.category)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(5)
                    
                    Toggle("Completed", isOn: $isCompleted)
                    
                    Toggle("Has Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as CategoryEntity?)
                        ForEach(coreDataStore.categories) { category in
                            HStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                                Text(category.name ?? "")
                            }
                            .tag(category as CategoryEntity?)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        coreDataStore.deleteTodoItem(task)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Task")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Update the task
                        coreDataStore.updateTodoItem(
                            task,
                            title: title,
                            isCompleted: isCompleted,
                            notes: notes,
                            dueDate: hasDueDate ? dueDate : nil,
                            category: selectedCategory
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    let context = CoreDataManager.shared.viewContext
    let task = TodoItemEntity(context: context)
    task.title = "Sample Task"
    task.notes = "This is a sample task for preview"
    task.isCompleted = false
    task.id = UUID()
    
    return TaskDetailView(task: task)
        .environmentObject(CoreDataTodoStore())
} 