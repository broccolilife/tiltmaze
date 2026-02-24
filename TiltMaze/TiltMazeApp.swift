import SwiftUI
import TipKit

@main
struct TiltMazeApp: App {
    init() {
        OnboardingConfig.setup()
    }

    var body: some Scene {
        WindowGroup {
            MazeGameView()
        }
    }
}
