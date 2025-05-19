import SwiftUI

// Category model
struct Category: Identifiable, Codable {
    let id = UUID()
    var name: String
    var color: CategoryColor
    
    // Color options for categories
    enum CategoryColor: String, CaseIterable, Identifiable, Codable {
        case red, orange, yellow, green, blue, purple, gray
        var id: Self { self }
        
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
}

// Category storage
class CategoryStore: ObservableObject {
    @Published var categories: [Category] = [] {
        didSet {
            saveCategories()
        }
    }
    
    private let categoriesKey = "todoCategories"
    
    init() {
        loadCategories()
        
        // Add default categories if none exist
        if categories.isEmpty {
            categories = [
                Category(name: "Personal", color: .blue),
                Category(name: "Work", color: .orange),
                Category(name: "Grocery", color: .green)
            ]
        }
    }
    
    private func saveCategories() {
        if let encodedData = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encodedData, forKey: categoriesKey)
        }
    }
    
    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.data(forKey: categoriesKey),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: savedCategories) {
            categories = decodedCategories
        }
    }
}

struct CategoryManager: View {
    @StateObject var categoryStore = CategoryStore()
    @State private var showingAddCategory = false
    @State private var editingCategory: Category?
    
    var body: some View {
        List {
            ForEach(categoryStore.categories) { category in
                HStack {
                    Circle()
                        .fill(category.color.color)
                        .frame(width: 20, height: 20)
                    
                    Text(category.name)
                    
                    Spacer()
                    
                    Button(action: {
                        editingCategory = category
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onDelete(perform: deleteCategories)
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    showingAddCategory = true
                }) {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            NavigationStack {
                CategoryEditView(categoryStore: categoryStore)
            }
        }
        .sheet(item: $editingCategory) { category in
            // Find the index of the category
            if let index = categoryStore.categories.firstIndex(where: { $0.id == category.id }) {
                NavigationStack {
                    CategoryEditView(categoryStore: categoryStore, editMode: true, categoryIndex: index)
                }
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        categoryStore.categories.remove(atOffsets: offsets)
    }
}

struct CategoryEditView: View {
    @ObservedObject var categoryStore: CategoryStore
    var editMode: Bool = false
    var categoryIndex: Int?
    
    @Environment(\.dismiss) private var dismiss
    @State private var categoryName: String = ""
    @State private var selectedColor: Category.CategoryColor = .blue
    
    init(categoryStore: CategoryStore, editMode: Bool = false, categoryIndex: Int? = nil) {
        self.categoryStore = categoryStore
        self.editMode = editMode
        self.categoryIndex = categoryIndex
        
        // Initialize state variables if in edit mode
        if let index = categoryIndex, editMode {
            let category = categoryStore.categories[index]
            _categoryName = State(initialValue: category.name)
            _selectedColor = State(initialValue: category.color)
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Category Details")) {
                TextField("Category Name", text: $categoryName)
                
                Picker("Color", selection: $selectedColor) {
                    ForEach(Category.CategoryColor.allCases) { colorOption in
                        HStack {
                            Circle()
                                .fill(colorOption.color)
                                .frame(width: 20, height: 20)
                            Text(colorOption.rawValue.capitalized)
                        }
                        .tag(colorOption)
                    }
                }
            }
        }
        .navigationTitle(editMode ? "Edit Category" : "New Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(editMode ? "Update" : "Add") {
                    if editMode, let index = categoryIndex {
                        // Update existing category
                        categoryStore.categories[index].name = categoryName
                        categoryStore.categories[index].color = selectedColor
                    } else {
                        // Add new category
                        let newCategory = Category(name: categoryName, color: selectedColor)
                        categoryStore.categories.append(newCategory)
                    }
                    dismiss()
                }
                .disabled(categoryName.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CategoryManager()
    }
} 