import SwiftUI

struct MazeGameView: View {
    @StateObject private var game = GameState()
    @State private var screenSize: CGSize = .zero
    @State private var showWin = false

    var body: some View {
        ZStack {
            // Background — deep black with subtle gradient
            LinearGradient(
                colors: [Tokens.GameColor.background, Tokens.GameColor.backgroundDeep, Tokens.GameColor.backgroundSubtle],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Maze walls
            MazeView(
                maze: game.maze,
                cellSize: game.cellSize,
                origin: game.mazeOrigin
            )

            // Ball trail
            TrailView(trail: game.trail, radius: game.ballRadius)

            // Ball
            BallView(
                position: game.ballPos,
                radius: game.ballRadius
            )

            // HUD — safe area aware
            VStack(spacing: 0) {
                HUDBar(game: game, screenSize: $screenSize)
                Spacer()
            }

            // Win overlay
            if game.hasWon {
                WinOverlay(game: game, screenSize: $screenSize)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(Tokens.Spring.reveal, value: game.hasWon)
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    screenSize = geo.size
                    game.configure(screenSize: geo.size)
                    game.startMotion()
                }
            }
        )
        .onDisappear { game.stopMotion() }
        .persistentSystemOverlays(.hidden)
        .preferredColorScheme(.dark)
        .statusBarHidden()
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
            .shadow(color: Tokens.GameColor.ballGlow, radius: 8, x: 0, y: 0)
            .shadow(color: Tokens.GameColor.ballGlow.opacity(0.5), radius: 16, x: 0, y: 0)
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
                .font(GameTypography.hud)
                .foregroundStyle(Tokens.GameColor.hudText)

            Spacer()

            // Timer
            Label(game.formattedTime, systemImage: "timer")
                .font(GameTypography.hudMono)
                .foregroundStyle(Tokens.GameColor.hudSecondary)
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
                    .font(GameTypography.hudMono)
                    .foregroundStyle(Tokens.GameColor.accent)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .padding(.horizontal, Tokens.Spacing.xl)
        .padding(.vertical, Tokens.Spacing.md)
        .background(
            .ultraThinMaterial.opacity(0.5),
            in: RoundedRectangle(cornerRadius: Tokens.Radius.lg)
        )
        .padding(.horizontal, Tokens.Spacing.lg)
        .padding(.top, Tokens.Spacing.xs)
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
                // Stars with staggered bounce
                HStack(spacing: Tokens.Spacing.sm) {
                    ForEach(0..<3) { i in
                        Image(systemName: i < starCount ? "star.fill" : "star")
                            .font(GameTypography.star)
                            .foregroundStyle(i < starCount ? Tokens.GameColor.starActive : Tokens.GameColor.starInactive)
                            .scaleEffect(i < starCount ? 1.0 : 0.8)
                            .phaseAnimator(i < starCount ? [false, true] : [false]) { content, phase in
                                content
                                    .scaleEffect(phase ? 1.15 : 1.0)
                                    .rotationEffect(.degrees(phase ? -8 : 0))
                            } animation: { _ in
                                Tokens.Spring.celebrate.delay(Double(i) * 0.12)
                            }
                    }
                }

                Text("Level \(game.level)")
                    .font(GameTypography.display)
                    .foregroundStyle(Tokens.GameColor.hudText)

                Text("Complete")
                    .font(GameTypography.uppercase)
                    .foregroundStyle(Tokens.GameColor.hudSecondary)
                    .textCase(.uppercase)
                    .kerning(2.5)

                // Stats card
                VStack(spacing: Tokens.Spacing.md) {
                    StatRow(icon: "timer", label: "Time", value: game.formattedTime)
                    Divider().overlay(.white.opacity(0.1))
                    StatRow(icon: "point.topleft.down.to.point.bottomright.curvepath", label: "Efficiency", value: efficiencyLabel)
                }
                .padding(Tokens.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: Tokens.Radius.lg)
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
                        .font(GameTypography.button)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Tokens.Spacing.lg)
                        .background(Tokens.GameColor.accent)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: 260)
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
                .foregroundStyle(Tokens.GameColor.accent)
                .frame(width: Tokens.Spacing.xxl)
            Text(label)
                .font(GameTypography.statLabel)
                .foregroundStyle(Tokens.GameColor.hudSecondary)
            Spacer()
            Text(value)
                .font(GameTypography.stat)
                .foregroundStyle(Tokens.GameColor.hudText)
        }
    }
}

#Preview {
    MazeGameView()
}
