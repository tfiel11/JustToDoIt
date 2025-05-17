//
//  ContentView.swift
//  JustToDoIt
//
//  Created by Tyler Fielding on 5/17/25.
//

import SwiftUI

struct ContentView: View {
    // Get access to the todoStore from the environment
    @EnvironmentObject var todoStore: TodoStore
    
    // State variable to track new item text
    @State private var newItemText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Input field for adding new to-do items
                HStack {
                    TextField("Enter a task", text: $newItemText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addItem) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                    .disabled(newItemText.isEmpty)
                }
                .padding()
                
                // List to display our to-do items
                List {
                    ForEach(todoStore.items.indices, id: \.self) { index in
                        HStack {
                            // Checkbox
                            Button(action: {
                                toggleItemCompletion(at: index)
                            }) {
                                Image(systemName: todoStore.items[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todoStore.items[index].isCompleted ? .green : .gray)
                            }
                            
                            // Item text
                            Text(todoStore.items[index].title)
                                .strikethrough(todoStore.items[index].isCompleted, color: .gray)
                                .foregroundColor(todoStore.items[index].isCompleted ? .gray : .primary)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Just To-Do It")
            .toolbar {
                EditButton()
            }
        }
    }
    
    // Function to add a new to-do item
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

#Preview {
    ContentView()
        .environmentObject(TodoStore())
}
