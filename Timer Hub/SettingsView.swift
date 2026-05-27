import SwiftUI

struct SettingsView: View {
    @AppStorage("colorSchemePreference") private var colorSchemePreference: String = "system"

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $colorSchemePreference) {
                        Label("System", systemImage: "circle.lefthalf.filled").tag("system")
                        Label("Light", systemImage: "sun.max").tag("light")
                        Label("Dark", systemImage: "moon").tag("dark")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Max Timers")
                        Spacer()
                        Text("\(TimerStore.maxTimers)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
