import SwiftUI

// A simple settings model
class AppSettings: ObservableObject {
    @Published var sortCompletedToBottom: Bool {
        didSet {
            UserDefaults.standard.set(sortCompletedToBottom, forKey: "sortCompletedToBottom")
        }
    }
    
    @Published var showCompletedTasks: Bool {
        didSet {
            UserDefaults.standard.set(showCompletedTasks, forKey: "showCompletedTasks")
        }
    }
    
    @Published var appColorTheme: ColorTheme {
        didSet {
            UserDefaults.standard.set(appColorTheme.rawValue, forKey: "appColorTheme")
        }
    }
    
    init() {
        // Load saved settings or use defaults
        self.sortCompletedToBottom = UserDefaults.standard.bool(forKey: "sortCompletedToBottom")
        self.showCompletedTasks = UserDefaults.standard.bool(forKey: "showCompletedTasks") 
        
        // Load color theme or use default
        if let savedTheme = UserDefaults.standard.string(forKey: "appColorTheme"),
           let theme = ColorTheme(rawValue: savedTheme) {
            self.appColorTheme = theme
        } else {
            self.appColorTheme = .blue
        }
    }
    
    // Available color themes
    enum ColorTheme: String, CaseIterable, Identifiable {
        case blue, green, purple, orange, red
        var id: Self { self }
        
        var color: Color {
            switch self {
            case .blue: return .blue
            case .green: return .green
            case .purple: return .purple
            case .orange: return .orange
            case .red: return .red
            }
        }
        
        var name: String {
            rawValue.capitalized
        }
    }
}

struct SettingsView: View {
    // Shared settings
    @StateObject private var settings = AppSettings()
    
    // State for showing about sheet
    @State private var showingAbout = false
    
    var body: some View {
        Form {
            Section(header: Text("Display Options")) {
                Toggle("Show Completed Tasks", isOn: $settings.showCompletedTasks)
                Toggle("Sort Completed to Bottom", isOn: $settings.sortCompletedToBottom)
            }
            
            Section(header: Text("Appearance")) {
                Picker("Color Theme", selection: $settings.appColorTheme) {
                    ForEach(AppSettings.ColorTheme.allCases) { theme in
                        HStack {
                            Circle()
                                .fill(theme.color)
                                .frame(width: 20, height: 20)
                            Text(theme.name)
                        }
                        .tag(theme)
                    }
                }
            }
            
            Section {
                Button("About Just To-Do It") {
                    showingAbout = true
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

// A simple About view
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Just To-Do It")
                    .font(.largeTitle)
                    .bold()
                
                Text("Version 1.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("A simple todo app built with SwiftUI for learning purposes.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
} 