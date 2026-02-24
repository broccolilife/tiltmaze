import SwiftUI

@main
struct TiltMazeApp: App {
    @State private var selectedTab: AppTab = .play

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TabView(selection: $selectedTab) {
                    MazeGameView()
                        .tabItem {
                            Label("Play", systemImage: "square.grid.3x3.fill")
                        }
                        .tag(AppTab.play)

                    LevelSelectView()
                        .tabItem {
                            Label("Levels", systemImage: "list.bullet")
                        }
                        .tag(AppTab.levels)

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .tag(AppTab.settings)
                }
                .tint(.cyan)
            }
        }
    }
}

enum AppTab: String {
    case play, levels, settings
}

// MARK: - Level Select (stub)
struct LevelSelectView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Levels")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                Text("Coming soon")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}

// MARK: - Settings (stub)
struct SettingsView: View {
    @AppStorage("showGhost") private var showGhost = true
    @AppStorage("haptics") private var hapticsEnabled = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            List {
                Section("Gameplay") {
                    Toggle("Show Ghost Replay", isOn: $showGhost)
                    Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
    }
}
