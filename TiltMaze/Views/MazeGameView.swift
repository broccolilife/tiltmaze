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
                    Button {
                        game.stopMotion()
                        game.maze = MazeGenerator(
                            rows: game.mazeRows, cols: game.mazeCols,
                            startRow: 0, startCol: 0
                        )
                        game.hasWon = false
                        game.configure(screenSize: screenSize)
                        game.startMotion()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer()
            }

            // Win overlay
            if game.hasWon {
                VStack(spacing: 20) {
                    Text("🎉")
                        .font(.system(size: 64))
                    Text("Level \(game.level) Complete!")
                        .font(.title.bold())
                        .foregroundStyle(.white)
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
}

#Preview {
    MazeGameView()
}
