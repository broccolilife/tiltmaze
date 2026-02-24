// DesignTokens.swift — TiltMaze
// Shared design tokens: colors, spacing, typography, corner radii

import SwiftUI

// MARK: - Semantic Colors

extension Color {
    static var surfacePrimary: Color { Color(uiColor: .systemBackground) }
    static var surfaceSecondary: Color { Color(uiColor: .secondarySystemBackground) }
    static var surfaceTertiary: Color { Color(uiColor: .tertiarySystemBackground) }

    static var textPrimary: Color { Color(uiColor: .label) }
    static var textSecondary: Color { Color(uiColor: .secondaryLabel) }
    static var textTertiary: Color { Color(uiColor: .tertiaryLabel) }

    // Maze palette — neon/electric
    static let mazeWall    = Color(red: 0.15, green: 0.15, blue: 0.25)
    static let mazePath    = Color(red: 0.92, green: 0.92, blue: 0.95)
    static let mazeAccent  = Color(red: 0.30, green: 0.65, blue: 1.00) // electric blue
    static let mazeGoal    = Color(red: 0.20, green: 0.85, blue: 0.55) // success green
    static let mazeBall    = Color(red: 0.95, green: 0.40, blue: 0.30) // ball red

    static let statusSuccess = Color(red: 0.30, green: 0.70, blue: 0.50)
    static let statusWarning = Color(red: 0.95, green: 0.68, blue: 0.35)
    static let statusDanger  = Color(red: 0.90, green: 0.35, blue: 0.38)

    static var borderDefault: Color { Color(uiColor: .separator) }
}

// MARK: - Spacing (8pt grid)

enum Spacing {
    static let xxs: CGFloat = 2;  static let xs: CGFloat = 4
    static let sm: CGFloat = 8;   static let md: CGFloat = 12
    static let base: CGFloat = 16; static let lg: CGFloat = 24
    static let xl: CGFloat = 32;  static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 48
}

// MARK: - Corner Radii

enum CornerRadius {
    static let sm: CGFloat = 8;  static let md: CGFloat = 12
    static let lg: CGFloat = 16; static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Typography

enum AppTypography {
    static let displayLarge: Font  = .system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium: Font = .system(size: 28, weight: .bold, design: .rounded)
    static let title: Font         = .system(size: 22, weight: .semibold, design: .rounded)
    static let headline: Font      = .system(size: 17, weight: .semibold)
    static let body: Font          = .system(size: 17, weight: .regular)
    static let callout: Font       = .system(size: 16, weight: .regular)
    static let subheadline: Font   = .system(size: 15, weight: .regular)
    static let footnote: Font      = .system(size: 13, weight: .regular)
    static let caption: Font       = .system(size: 12, weight: .regular)
    static let captionBold: Font   = .system(size: 12, weight: .semibold)
}
