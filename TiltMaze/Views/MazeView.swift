import SwiftUI

/// Renders the maze grid walls.
struct MazeView: View {
    let maze: MazeGenerator
    let cellSize: CGFloat
    let origin: CGPoint

    var body: some View {
        Canvas { context, size in
            let wallWidth: CGFloat = 2

            // Draw walls
            for row in 0..<maze.rows {
                for col in 0..<maze.cols {
                    let cell = maze.grid[row][col]
                    let x = origin.x + CGFloat(col) * cellSize
                    let y = origin.y + CGFloat(row) * cellSize

                    if cell.top {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: x + cellSize, y: y))
                        context.stroke(path, with: .color(.white), lineWidth: wallWidth)
                    }
                    if cell.bottom {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: y + cellSize))
                        path.addLine(to: CGPoint(x: x + cellSize, y: y + cellSize))
                        context.stroke(path, with: .color(.white), lineWidth: wallWidth)
                    }
                    if cell.left {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: x, y: y + cellSize))
                        context.stroke(path, with: .color(.white), lineWidth: wallWidth)
                    }
                    if cell.right {
                        var path = Path()
                        path.move(to: CGPoint(x: x + cellSize, y: y))
                        path.addLine(to: CGPoint(x: x + cellSize, y: y + cellSize))
                        context.stroke(path, with: .color(.white), lineWidth: wallWidth)
                    }
                }
            }

            // Draw end marker
            let endX = origin.x + CGFloat(maze.end.col) * cellSize + cellSize * 0.2
            let endY = origin.y + CGFloat(maze.end.row) * cellSize + cellSize * 0.2
            let endSize = cellSize * 0.6
            let endRect = CGRect(x: endX, y: endY, width: endSize, height: endSize)
            context.fill(Path(roundedRect: endRect, cornerRadius: 4), with: .color(.green.opacity(0.5)))
            context.stroke(Path(roundedRect: endRect, cornerRadius: 4), with: .color(.green), lineWidth: 1.5)
        }
    }
}
