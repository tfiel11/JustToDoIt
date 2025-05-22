//
//  ContentView.swift
//  JustToDoIt
//
//  Created by Tyler Fielding on 5/17/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coreDataStore: CoreDataTodoStore
    
    var body: some View {
        NavigationStack {
            TaskListView()
        }
    }
}

struct TaskListView: View {
    @EnvironmentObject private var coreDataStore: CoreDataTodoStore
    @State private var showingAddTask = false
    @State private var selectedCategory: CategoryEntity?
    @State private var searchText = ""
    @State private var showingCompleted = true
    @State private var showingCategorySheet = false
    
    // Filtered tasks based on search, category and completion status
    private var filteredTasks: [TodoItemEntity] {
        var tasks = coreDataStore.todoItems
        
        // Filter by category if one is selected
        if let category = selectedCategory {
            tasks = tasks.filter { $0.category == category }
        }
        
        // Filter by completion status
        if !showingCompleted {
            tasks = tasks.filter { !$0.isCompleted }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            tasks = tasks.filter { ($0.title ?? "").localizedCaseInsensitiveContains(searchText) }
        }
        
        return tasks
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Category selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Button(action: {
                            selectedCategory = nil
                        }) {
                            Text("All")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == nil ? .white : .primary)
                                .cornerRadius(20)
                        }
                        
                        ForEach(coreDataStore.categories) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                HStack {
                                    Circle()
                                        .fill(category.color)
                                        .frame(width: 12, height: 12)
                                    Text(category.name ?? "")
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? category.color.opacity(0.8) : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search tasks", text: $searchText)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Category title header
                if let category = selectedCategory {
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 12, height: 12)
                        Text(category.name ?? "")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            selectedCategory = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                List {
                    if filteredTasks.isEmpty {
                        Text("No tasks found")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 30)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredTasks) { task in
                            TaskRow(task: task)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        coreDataStore.deleteTodoItem(task)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        coreDataStore.toggleCompletion(for: task)
                                    } label: {
                                        Label(
                                            task.isCompleted ? "Mark Incomplete" : "Mark Complete", 
                                            systemImage: task.isCompleted ? "circle" : "checkmark.circle"
                                        )
                                    }
                                    .tint(task.isCompleted ? .gray : .green)
                                }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            
            // Add task button
            Button(action: {
                showingAddTask = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Color.accentColor))
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            .padding([.trailing, .bottom], 20)
            .accessibilityLabel("Add Task")
        }
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingCompleted.toggle()
                    }) {
                        Label(
                            showingCompleted ? "Hide Completed" : "Show Completed",
                            systemImage: showingCompleted ? "eye.slash" : "eye"
                        )
                    }
                    
                    Divider()
                    
                    Button(action: {
                        // Reset all filters
                        selectedCategory = nil
                        showingCompleted = true
                        searchText = ""
                    }) {
                        Label("Reset All Filters", systemImage: "arrow.clockwise")
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button(action: {
                        showingCategorySheet = true
                    }) {
                        Label("Manage Categories", systemImage: "folder.badge.gear")
                    }
                    
                    Divider()
                    
                    ForEach(coreDataStore.categories) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            HStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 10, height: 10)
                                Text(category.name ?? "")
                            }
                        }
                    }
                } label: {
                    Label("Categories", systemImage: "folder")
                        .font(.system(size: 16, weight: .regular))
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(isPresented: $showingAddTask)
        }
        .sheet(isPresented: $showingCategorySheet) {
            CategoryView()
        }
    }
}

// Task row component
struct TaskRow: View {
    @EnvironmentObject private var coreDataStore: CoreDataTodoStore
    @State private var showingTaskDetail = false
    let task: TodoItemEntity
    
    var body: some View {
        Button(action: {
            showingTaskDetail = true
        }) {
            HStack(spacing: 12) {
                Button(action: {
                    coreDataStore.toggleCompletion(for: task)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                        .font(.system(size: 22))
                }
                .buttonStyle(BorderlessButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title ?? "")
                        .font(.system(size: 16, weight: .medium))
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                Text(dueDate, style: .date)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .foregroundColor(.blue)
                        }
                        
                        if let notes = task.notes, !notes.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text")
                                    .font(.caption)
                                Text(notes)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                if let category = task.category {
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 10, height: 10)
                        Text(category.name ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingTaskDetail) {
            TaskDetailView(task: task)
        }
        .padding(.vertical, 8)
    }
}

// Add task view
struct AddTaskView: View {
    @EnvironmentObject private var coreDataStore: CoreDataTodoStore
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var selectedCategory: CategoryEntity?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes)
                    
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
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        coreDataStore.addTodoItem(
                            title: title,
                            isCompleted: false,
                            notes: notes,
                            dueDate: hasDueDate ? dueDate : nil,
                            category: selectedCategory
                        )
                        isPresented = false
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CoreDataTodoStore())
}

