import SwiftUI
import TipKit

struct MazeGameView: View {
    @StateObject private var game = GameState()
    @State private var screenSize: CGSize = .zero
    @State private var showWin = false
    @State private var motionUnavailable = false

    private let tiltTip = TiltToMoveTip()
    private let goalTip = FindTheGoalTip()

    var body: some View {
        ZStack {
            // Background — deep black with subtle gradient
            LinearGradient(
                colors: [DS.Colors.background, .black, Color(white: 0.02)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if motionUnavailable {
                ErrorStateView.motionUnavailable {
                    motionUnavailable = false
                    game.startMotion()
                }
            } else {
                gameContent
            }
        }
        .animation(DS.Animation.standard, value: game.hasWon)
        .animation(DS.Animation.standard, value: motionUnavailable)
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    screenSize = geo.size
                    game.configure(screenSize: geo.size)
                    if game.isMotionAvailable {
                        game.startMotion()
                    } else {
                        motionUnavailable = true
                    }
                }
            }
        )
        .onDisappear { game.stopMotion() }
        .persistentSystemOverlays(.hidden)
        .preferredColorScheme(.dark)
        .statusBarHidden()
    }

    @ViewBuilder
    private var gameContent: some View {
        // Maze walls
        MazeView(
            maze: game.maze,
            cellSize: game.cellSize,
            origin: game.mazeOrigin
        )
        .accessibilityLabel("Maze grid, level \(game.level)")

        // Ball trail
        TrailView(trail: game.trail, radius: game.ballRadius)
            .accessibilityHidden(true)

        // Ball
        BallView(
            position: game.ballPos,
            radius: game.ballRadius
        )
        .accessibilityLabel("Your ball")
        .accessibilityValue("Position in maze")

        // HUD — safe area aware
        VStack(spacing: 0) {
            HUDBar(game: game, screenSize: $screenSize)
            // Onboarding tip — tilt instruction
            TipView(tiltTip)
                .padding(.horizontal, DS.Spacing.lg)
                .tipBackground(DS.Colors.overlayDim)
            Spacer()
        }

        // Win overlay
        if game.hasWon {
            WinOverlay(game: game, screenSize: $screenSize)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .onAppear {
                    FindTheGoalTip.hasCompletedFirstLevel = true
                    NewMazeTip.levelsCompleted += 1
                    StarRatingTip.hasSeenWinScreen = true
                }
        }
    }
}

// MARK: - Trail View

private struct TrailView: View {
    let trail: [CGPoint]
    let radius: CGFloat

    var body: some View {
        Canvas { context, size in
            guard trail.count >= 2 else { return }

            for (i, point) in trail.enumerated() {
                let progress = CGFloat(i) / CGFloat(trail.count)
                let r = radius * (0.3 + progress * 0.7)
                let opacity = Double(progress) * 0.5

                let rect = CGRect(
                    x: point.x - r,
                    y: point.y - r,
                    width: r * 2,
                    height: r * 2
                )
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(.cyan.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Ball View

private struct BallView: View {
    let position: CGPoint
    let radius: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.white, .cyan.opacity(0.9), .blue.opacity(0.6)],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: radius * 1.2
                )
            )
            .frame(width: radius * 2, height: radius * 2)
            .shadow(color: .cyan.opacity(0.6), radius: 8, x: 0, y: 0)
            .shadow(color: .cyan.opacity(0.3), radius: 16, x: 0, y: 0)
            .position(position)
    }
}

// MARK: - HUD Bar

private struct HUDBar: View {
    @ObservedObject var game: GameState
    @Binding var screenSize: CGSize

    var body: some View {
        HStack(spacing: 0) {
            // Level pill
            Label("Level \(game.level)", systemImage: "square.grid.3x3")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Spacer()

            // Timer
            Label(game.formattedTime, systemImage: "timer")
                .font(.subheadline.weight(.medium).monospacedDigit())
                .foregroundStyle(.white.opacity(0.7))
                .contentTransition(.numericText())

            Spacer()

            // New maze button
            Button {
                game.stopMotion()
                game.resetMaze()
                game.configure(screenSize: screenSize)
                game.startMotion()
            } label: {
                Label("New", systemImage: "arrow.trianglehead.2.counterclockwise")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DS.Colors.accent)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .accessibilityLabel("Generate new maze")
            .accessibilityHint("Creates a fresh maze at the current difficulty")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            .ultraThinMaterial.opacity(0.5),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}

// MARK: - Win Overlay

private struct WinOverlay: View {
    @ObservedObject var game: GameState
    @Binding var screenSize: CGSize

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Stars
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Image(systemName: i < starCount ? "star.fill" : "star")
                            .font(.title)
                            .foregroundStyle(i < starCount ? .yellow : .white.opacity(0.3))
                            .scaleEffect(i < starCount ? 1.0 : 0.8)
                    }
                }

                Text("Level \(game.level)")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                Text("Complete")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .kerning(2)

                // Stats card
                VStack(spacing: 12) {
                    StatRow(icon: "timer", label: "Time", value: game.formattedTime)
                    Divider().overlay(.white.opacity(0.1))
                    StatRow(icon: "point.topleft.down.to.point.bottomright.curvepath", label: "Efficiency", value: efficiencyLabel)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .frame(maxWidth: 260)

                // Next level button
                Button {
                    game.newGame()
                    game.configure(screenSize: screenSize)
                    game.startMotion()
                } label: {
                    Text("Next Level")
                        .font(DS.Typography.button)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.lg)
                        .background(DS.Colors.accent)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: DS.Layout.winCardMaxWidth)
                .accessibilityLabel("Continue to level \(game.level + 1)")
            }
            .padding(32)
        }
    }

    private var starCount: Int {
        let ratio = game.struggleRatio
        if ratio < 1.3 { return 3 }
        if ratio < 2.0 { return 2 }
        if ratio < 3.5 { return 1 }
        return 0
    }

    private var efficiencyLabel: String {
        let ratio = game.struggleRatio
        if ratio < 1.3 { return "Perfect" }
        if ratio < 2.0 { return "Great" }
        if ratio < 3.5 { return "Good" }
        return "Keep going"
    }
}

// MARK: - Stat Row

private struct StatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.cyan)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    MazeGameView()
}
