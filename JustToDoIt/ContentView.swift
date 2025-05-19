//
//  ContentView.swift
//  JustToDoIt
//
//  Created by Tyler Fielding on 5/17/25.
//

import SwiftUI

struct ContentView: View {
    // Get access to the stores from the environment
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var categoryStore: CategoryStore
    
    // State variables
    @State private var newItemText = ""
    @State private var showingAddTaskSheet = false
    
    var body: some View {
        // Main navigation with tab view
        TabView {
            // Tab 1: Tasks List
            taskListView
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
            
            // Tab 2: Categories
            NavigationStack {
                CategoryManager()
                    .environmentObject(categoryStore)
            }
            .tabItem {
                Label("Categories", systemImage: "folder")
            }
            
            // Tab 3: Settings
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
    
    // Task List View
    private var taskListView: some View {
        NavigationStack {
            VStack {
                // Input field for adding new to-do items
                HStack {
                    TextField("Enter a task", text: $newItemText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        // Show detailed task creation sheet instead of simple addition
                        showingAddTaskSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
                .padding()
                
                // List to display our to-do items
                List {
                    ForEach(todoStore.items.indices, id: \.self) { index in
                        taskRow(for: index)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Just To-Do It")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddTaskSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskSheet) {
                NavigationStack {
                    AddTaskView(todoStore: todoStore, categoryStore: categoryStore)
                        .environmentObject(todoStore)
                        .environmentObject(categoryStore)
                }
            }
        }
    }
    
    // Task row view with navigation link
    private func taskRow(for index: Int) -> some View {
        // Check if the item exists at this index
        guard index < todoStore.items.count else {
            return AnyView(EmptyView())
        }
        
        // Create a navigation link to the task detail view
        return AnyView(
            NavigationLink(destination: 
                TaskDetailView(itemIndex: index, todoStore: todoStore)
                    .environmentObject(todoStore)
                    .environmentObject(categoryStore)
            ) {
                HStack {
                    // Checkbox
                    Button(action: {
                        toggleItemCompletion(at: index)
                    }) {
                        Image(systemName: todoStore.items[index].isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(todoStore.items[index].isCompleted ? .green : .gray)
                    }
                    
                    // Item text
                    VStack(alignment: .leading) {
                        Text(todoStore.items[index].title)
                            .strikethrough(todoStore.items[index].isCompleted, color: .gray)
                            .foregroundColor(todoStore.items[index].isCompleted ? .gray : .primary)
                        
                        // If there's a category, show it
                        if let categoryId = todoStore.items[index].categoryId,
                           let category = categoryStore.categories.first(where: { $0.id == categoryId }) {
                            Text(category.name)
                                .font(.caption)
                                .foregroundColor(category.color.color)
                        }
                    }
                    
                    // If there's a due date, show it
                    if let dueDate = todoStore.items[index].dueDate {
                        Spacer()
                        Text(dueDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        )
    }
    
    // Function to add a simple to-do item (from text field)
    private func addItem() {
        if !newItemText.isEmpty {
            todoStore.items.append(TodoItem(title: newItemText, isCompleted: false))
            newItemText = ""
        }
    }
    
    // Function to toggle completion status
    private func toggleItemCompletion(at index: Int) {
        todoStore.items[index].isCompleted.toggle()
    }
    
    // Function to delete to-do items
    private func deleteItems(at offsets: IndexSet) {
        todoStore.items.remove(atOffsets: offsets)
    }
}

// Add Task View (Sheet)
struct AddTaskView: View {
    @ObservedObject var todoStore: TodoStore
    @ObservedObject var categoryStore: CategoryStore
    
    @State private var taskTitle = ""
    @State private var notes = ""
    @State private var selectedCategoryId: UUID? = nil
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Task Details")) {
                TextField("Task Title", text: $taskTitle)
                
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
                Toggle("Has Due Date", isOn: $hasDueDate)
                
                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
            }
        }
        .navigationTitle("Add Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    // Create and add new task
                    let newTask = TodoItem(
                        title: taskTitle,
                        isCompleted: false,
                        categoryId: selectedCategoryId,
                        notes: notes,
                        dueDate: hasDueDate ? dueDate : nil
                    )
                    todoStore.items.append(newTask)
                    dismiss()
                }
                .disabled(taskTitle.isEmpty)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoStore())
        .environmentObject(CategoryStore())
}

