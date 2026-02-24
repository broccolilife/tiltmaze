import SwiftUI
import TipKit

// MARK: - TipKit Onboarding
// Progressive disclosure: show tips contextually, not all at once.
// Zero-friction: gameplay starts immediately, tips appear naturally.

/// Tip: How to play — shown on first launch
struct TiltToMoveTip: Tip {
    var title: Text {
        Text("Tilt to Navigate")
    }

    var message: Text? {
        Text("Hold your phone flat and tilt to roll the ball through the maze.")
    }

    var image: Image? {
        Image(systemName: "iphone.gen3.radiowaves.left.and.right")
    }
}

/// Tip: Goal marker explanation
struct FindTheGoalTip: Tip {
    @Parameter
    static var hasCompletedFirstLevel: Bool = false

    var title: Text {
        Text("Reach the Green Circle")
    }

    var message: Text? {
        Text("Navigate to the glowing green goal to complete the level.")
    }

    var image: Image? {
        Image(systemName: "scope")
    }

    var rules: [Rule] {
        [
            #Rule(Self.$hasCompletedFirstLevel) { $0 == false }
        ]
    }
}

/// Tip: New maze button
struct NewMazeTip: Tip {
    @Parameter
    static var levelsCompleted: Int = 0

    var title: Text {
        Text("Stuck? Try a New Maze")
    }

    var message: Text? {
        Text("Tap 'New' in the top bar to generate a fresh maze.")
    }

    var image: Image? {
        Image(systemName: "arrow.trianglehead.2.counterclockwise")
    }

    var rules: [Rule] {
        [
            #Rule(Self.$levelsCompleted) { $0 >= 1 }
        ]
    }
}

/// Tip: Star rating system
struct StarRatingTip: Tip {
    @Parameter
    static var hasSeenWinScreen: Bool = false

    var title: Text {
        Text("Earn 3 Stars")
    }

    var message: Text? {
        Text("Take the shortest path to earn a perfect rating. Less wandering = more stars!")
    }

    var image: Image? {
        Image(systemName: "star.fill")
    }

    var rules: [Rule] {
        [
            #Rule(Self.$hasSeenWinScreen) { $0 == true }
        ]
    }
}

// MARK: - Onboarding Configuration

enum OnboardingConfig {
    static func setup() {
        try? Tips.configure([
            .displayFrequency(.daily),
            .datastoreLocation(.applicationDefault)
        ])
    }
}
