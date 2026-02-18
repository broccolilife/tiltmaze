import SwiftUI

struct MazeGameView: View {
    @StateObject private var game = GameState()
    @State private var screenSize: CGSize = .zero
    @State private var showWin = false

    var body: some View {
        ZStack {
            // Background — deep black with subtle gradient
            LinearGradient(
                colors: [Color(white: 0.03), .black, Color(white: 0.02)],
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
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: game.hasWon)
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
                    .foregroundStyle(.cyan)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
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
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.cyan)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
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
