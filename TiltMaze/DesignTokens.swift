import SwiftUI

// MARK: - Design Tokens

/// Centralized design token system for TiltMaze.
/// All magic numbers route through here for consistency and easy theming.
enum Tokens {

    // MARK: Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: Corner Radii

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 14
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    // MARK: Spring Animations

    enum Spring {
        /// Win overlay appearance
        static let reveal = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)

        /// Ball-related motion
        static let ball = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)

        /// Bouncy celebration (stars, score reveal)
        static let celebrate = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.55, blendDuration: 0.15)

        /// Button press feedback
        static let tap = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.8)

        /// Smooth scale transitions
        static let smooth = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.85)
    }

    // MARK: Colors

    enum GameColor {
        static let accent = Color.cyan
        static let background = Color(white: 0.03)
        static let backgroundDeep = Color.black
        static let backgroundSubtle = Color(white: 0.02)
        static let hudText = Color.white
        static let hudSecondary = Color.white.opacity(0.7)
        static let starActive = Color.yellow
        static let starInactive = Color.white.opacity(0.3)
        static let ballGlow = Color.cyan.opacity(0.6)
        static let trailColor = Color.cyan
    }
}

// MARK: - Game Typography

/// Semantic typography for the maze game UI.
enum GameTypography {
    /// Large win text
    static let display: Font = .system(.largeTitle, design: .rounded).weight(.bold)

    /// Level label, section heading
    static let heading: Font = .system(.title3, design: .rounded).weight(.medium)

    /// HUD labels
    static let hud: Font = .system(.subheadline, design: .rounded).weight(.semibold)

    /// HUD secondary (timer)
    static let hudMono: Font = .system(.subheadline, design: .monospaced).weight(.medium)

    /// Button labels
    static let button: Font = .system(.headline, design: .rounded)

    /// Stats
    static let stat: Font = .system(.subheadline, design: .rounded).weight(.semibold)

    /// Stat label
    static let statLabel: Font = .system(.subheadline, design: .rounded)

    /// Uppercase accent text
    static let uppercase: Font = .system(.caption, design: .rounded).weight(.semibold)

    /// Star icons
    static let star: Font = .system(.title, design: .rounded)
}
