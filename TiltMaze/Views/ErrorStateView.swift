import SwiftUI

/// Reusable error state view following Nielsen's Heuristic #9:
/// "Help Users Recover from Errors"
/// Every error shows: illustration, clear message, actionable button.
struct ErrorStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionLabel: String
    var secondaryLabel: String? = nil
    let action: () -> Void
    var secondaryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: DS.Spacing.xxl) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(DS.Colors.accent.opacity(0.6))
                .accessibilityHidden(true)

            VStack(spacing: DS.Spacing.sm) {
                Text(title)
                    .font(DS.Typography.subtitle)
                    .foregroundStyle(DS.Colors.hudText)

                Text(message)
                    .font(DS.Typography.statLabel)
                    .foregroundStyle(DS.Colors.hudTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: DS.Spacing.md) {
                Button(action: action) {
                    Text(actionLabel)
                        .font(DS.Typography.button)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.lg)
                        .background(DS.Colors.accent)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                }
                .buttonStyle(.plain)

                if let secondaryLabel, let secondaryAction {
                    Button(action: secondaryAction) {
                        Text(secondaryLabel)
                            .font(DS.Typography.statLabel)
                            .foregroundStyle(DS.Colors.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: DS.Layout.winCardMaxWidth)
        }
        .padding(DS.Spacing.xxxl)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preset Error States

extension ErrorStateView {
    /// Motion sensors unavailable (simulator, broken hardware)
    static func motionUnavailable(retry: @escaping () -> Void) -> ErrorStateView {
        ErrorStateView(
            icon: "gyroscope",
            title: "Motion Sensors Unavailable",
            message: "TiltMaze needs your device's accelerometer to play. Make sure you're on a physical iPhone.",
            actionLabel: "Try Again",
            action: retry
        )
    }

    /// Generic game error with recovery
    static func gameError(message: String, retry: @escaping () -> Void) -> ErrorStateView {
        ErrorStateView(
            icon: "exclamationmark.triangle",
            title: "Something Went Wrong",
            message: message,
            actionLabel: "Restart Level",
            secondaryLabel: "New Maze",
            action: retry
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ErrorStateView.motionUnavailable { }
    }
}
