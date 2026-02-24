import SwiftUI

// MARK: - Design Tokens
// Centralized design system. Every magic number flows from here.
// Based on iOS HIG spacing scale and 8pt grid.

enum DS {
    // MARK: Spacing (8pt grid)
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    // MARK: Colors — Game Palette
    enum Colors {
        static let background = Color(white: 0.03)
        static let wallColor = Color.white.opacity(0.85)
        static let wallBorder = Color.white.opacity(0.4)
        static let ballGlow = Color.cyan.opacity(0.6)
        static let trailColor = Color.cyan
        static let goalGlow = Color.green.opacity(0.15)
        static let goalFill = Color.green.opacity(0.6)
        static let goalStroke = Color.green
        static let accent = Color.cyan
        static let hudText = Color.white
        static let hudTextSecondary = Color.white.opacity(0.7)
        static let overlayDim = Color.black.opacity(0.6)
        static let starActive = Color.yellow
        static let starInactive = Color.white.opacity(0.3)
    }

    // MARK: Typography
    enum Typography {
        static let hudLabel = Font.subheadline.weight(.semibold)
        static let hudTimer = Font.subheadline.weight(.medium).monospacedDigit()
        static let levelTitle = Font.largeTitle.weight(.bold)
        static let subtitle = Font.title3.weight(.medium)
        static let button = Font.headline
        static let statLabel = Font.subheadline
        static let statValue = Font.subheadline.weight(.semibold)
    }

    // MARK: Animation
    enum Animation {
        static let springResponse: CGFloat = 0.4
        static let springDamping: CGFloat = 0.8
        static let bounceResponse: CGFloat = 0.35
        static let bounceDamping: CGFloat = 0.65

        static var standard: SwiftUI.Animation {
            .spring(response: springResponse, dampingFraction: springDamping)
        }
        static var bouncy: SwiftUI.Animation {
            .spring(response: bounceResponse, dampingFraction: bounceDamping)
        }
    }

    // MARK: Layout
    enum Layout {
        static let mazePadding: CGFloat = 20
        static let hudPaddingH: CGFloat = 20
        static let hudPaddingV: CGFloat = 12
        static let winCardMaxWidth: CGFloat = 260
        static let ballRadius: CGFloat = 6
        static let wallWidth: CGFloat = 1.5
        static let trailLength = 25
    }
}
