import SwiftUI

struct MazeGameView: View {
    @StateObject private var game = GameState()
    @State private var screenSize: CGSize = .zero

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            // Maze walls
            MazeView(
                maze: game.maze,
                cellSize: game.cellSize,
                origin: game.mazeOrigin
            )

            // Ball
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, .cyan, .blue],
                        center: .center,
                        startRadius: 0,
                        endRadius: game.ballRadius
                    )
                )
                .frame(width: game.ballRadius * 2, height: game.ballRadius * 2)
                .shadow(color: .cyan.opacity(0.8), radius: 6)
                .position(game.ballPos)

            // HUD
            VStack {
                HStack {
                    Text("Level \(game.level)")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    // Timer
                    Text(game.formattedTime)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    // New maze button
                    Button {
                        game.stopMotion()
                        game.resetMaze()
                        game.configure(screenSize: screenSize)
                        game.startMotion()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("New Maze")
                                .font(.caption)
                        }
                        .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer()
            }

            // Win overlay
            if game.hasWon {
                VStack(spacing: 16) {
                    Text("🎉")
                        .font(.system(size: 64))
                    Text("Level \(game.level) Complete!")
                        .font(.title.bold())
                        .foregroundStyle(.white)

                    // Stats
                    VStack(spacing: 6) {
                        HStack {
                            Text("⏱ Time:")
                            Spacer()
                            Text(game.formattedTime)
                        }
                        HStack {
                            Text("📐 Efficiency:")
                            Spacer()
                            Text(efficiencyLabel)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: 200)
                    .padding()
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button("Next Level") {
                        game.newGame()
                        game.configure(screenSize: screenSize)
                        game.startMotion()
                    }
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(.cyan)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.7))
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    screenSize = geo.size
                    game.configure(screenSize: geo.size)
                    game.startMotion()
                }
            }
        )
        .onDisappear {
            game.stopMotion()
        }
        .persistentSystemOverlays(.hidden)
    }

    private var efficiencyLabel: String {
        let ratio = game.struggleRatio
        if ratio < 1.3 { return "⭐⭐⭐ Perfect!" }
        if ratio < 2.0 { return "⭐⭐ Great" }
        if ratio < 3.5 { return "⭐ Good" }
        return "🔄 Keep trying!"
    }
}

#Preview {
    MazeGameView()
}
