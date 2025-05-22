import SwiftUI

struct CategoryView: View {
    @EnvironmentObject private var coreDataStore: CoreDataTodoStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddCategory = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(coreDataStore.categories) { category in
                    CategoryRow(category: category)
                }
                .onDelete(perform: deleteCategories)
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(isPresented: $showingAddCategory)
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            if index < coreDataStore.categories.count {
                coreDataStore.deleteCategory(coreDataStore.categories[index])
            }
        }
    }
}

struct CategoryRow: View {
    @EnvironmentObject private var coreDataStore: CoreDataTodoStore
    @State private var showingEditSheet = false
    let category: CategoryEntity
    
    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 20, height: 20)
            
            Text(category.name ?? "")
            
            Spacer()
            
            // Show task count
            Text("\(coreDataStore.todos(for: category).count) tasks")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button {
                showingEditSheet = true
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCategoryView(category: category, isPresented: $showingEditSheet)
        }
    }
}

struct AddCategoryView: View {
    @EnvironmentObject private var coreDataStore: CoreDataTodoStore
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var selectedColorName = "blue"
    
    private let colorOptions = CategoryEntity.CategoryColor.allCases
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $name)
                    
                    Picker("Color", selection: $selectedColorName) {
                        ForEach(colorOptions, id: \.self) { colorOption in
                            HStack {
                                Circle()
                                    .fill(colorOption.color)
                                    .frame(width: 20, height: 20)
                                Text(colorOption.rawValue.capitalized)
                            }
                            .tag(colorOption.rawValue)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Preview:")
                        Spacer()
                        CategoryPreview(name: name, colorName: selectedColorName)
                    }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        coreDataStore.addCategory(name: name, colorName: selectedColorName)
                        isPresented = false
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct EditCategoryView: View {
    @EnvironmentObject private var coreDataStore: CoreDataTodoStore
    let category: CategoryEntity
    @Binding var isPresented: Bool
    @State private var name: String
    @State private var selectedColorName: String
    
    private let colorOptions = CategoryEntity.CategoryColor.allCases
    
    init(category: CategoryEntity, isPresented: Binding<Bool>) {
        self.category = category
        self._isPresented = isPresented
        self._name = State(initialValue: category.name ?? "")
        self._selectedColorName = State(initialValue: category.colorName ?? "blue")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $name)
                    
                    Picker("Color", selection: $selectedColorName) {
                        ForEach(colorOptions, id: \.self) { colorOption in
                            HStack {
                                Circle()
                                    .fill(colorOption.color)
                                    .frame(width: 20, height: 20)
                                Text(colorOption.rawValue.capitalized)
                            }
                            .tag(colorOption.rawValue)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Preview:")
                        Spacer()
                        CategoryPreview(name: name, colorName: selectedColorName)
                    }
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        coreDataStore.updateCategory(category, name: name, colorName: selectedColorName)
                        isPresented = false
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct CategoryPreview: View {
    let name: String
    let colorName: String
    
    var color: Color {
        if let categoryColor = CategoryEntity.CategoryColor(rawValue: colorName) {
            return categoryColor.color
        }
        return .blue
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(name.isEmpty ? "Category Name" : name)
                .foregroundColor(Color.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    CategoryView()
        .environmentObject(CoreDataTodoStore())
} 