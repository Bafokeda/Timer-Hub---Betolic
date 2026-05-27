import SwiftUI

@main
struct Timer_HubApp: App {

    private static let openWebView = false

    @StateObject private var store = TimerStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            if Self.openWebView {
                WebViewScreen()
            } else {
                ContentView()
                    .environmentObject(store)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard !Self.openWebView else { return }
            switch newPhase {
            case .background: store.handleBackground()
            case .active:     store.handleForeground()
            default: break
            }
        }
    }
}
