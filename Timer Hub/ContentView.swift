import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: TimerStore
    @AppStorage("colorSchemePreference") private var colorSchemePreference: String = "system"

    var preferredColorScheme: ColorScheme? {
        switch colorSchemePreference {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Timers", systemImage: "timer") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .preferredColorScheme(preferredColorScheme)
    }
}

#Preview {
    ContentView()
}
