import SwiftUI

/// Renders the maze grid walls using Canvas for high performance.
struct MazeView: View {
    let maze: MazeGenerator
    let cellSize: CGFloat
    let origin: CGPoint

    var body: some View {
        Canvas { context, size in
            drawWalls(context: context)
            drawGoal(context: context)
        }
    }

    // MARK: - Wall Rendering

    private func drawWalls(context: GraphicsContext) {
        // Outer border — slightly thicker
        let mazeRect = CGRect(
            x: origin.x,
            y: origin.y,
            width: CGFloat(maze.cols) * cellSize,
            height: CGFloat(maze.rows) * cellSize
        )
        context.stroke(
            Path(roundedRect: mazeRect, cornerRadius: 2),
            with: .color(.white.opacity(0.4)),
            lineWidth: 1.5
        )

        // Interior walls — clean, consistent weight
        let wallColor = GraphicsContext.Shading.color(.white.opacity(0.85))
        let wallWidth: CGFloat = 1.5

        for row in 0..<maze.rows {
            for col in 0..<maze.cols {
                let cell = maze.grid[row][col]
                let x = origin.x + CGFloat(col) * cellSize
                let y = origin.y + CGFloat(row) * cellSize

                // Only draw bottom and right walls to avoid double-drawing
                // (top/left are drawn by neighboring cells)
                // Exception: first row draws top, first column draws left

                if row == 0 && cell.top {
                    drawLine(context: context, from: CGPoint(x: x, y: y),
                             to: CGPoint(x: x + cellSize, y: y),
                             color: wallColor, width: wallWidth)
                }
                if col == 0 && cell.left {
                    drawLine(context: context, from: CGPoint(x: x, y: y),
                             to: CGPoint(x: x, y: y + cellSize),
                             color: wallColor, width: wallWidth)
                }
                if cell.bottom {
                    drawLine(context: context, from: CGPoint(x: x, y: y + cellSize),
                             to: CGPoint(x: x + cellSize, y: y + cellSize),
                             color: wallColor, width: wallWidth)
                }
                if cell.right {
                    drawLine(context: context, from: CGPoint(x: x + cellSize, y: y),
                             to: CGPoint(x: x + cellSize, y: y + cellSize),
                             color: wallColor, width: wallWidth)
                }
            }
        }
    }

    private func drawLine(context: GraphicsContext, from: CGPoint, to: CGPoint,
                          color: GraphicsContext.Shading, width: CGFloat) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        context.stroke(path, with: color, style: StrokeStyle(lineWidth: width, lineCap: .round))
    }

    // MARK: - Goal Marker

    private func drawGoal(context: GraphicsContext) {
        let cx = origin.x + CGFloat(maze.end.col) * cellSize + cellSize / 2
        let cy = origin.y + CGFloat(maze.end.row) * cellSize + cellSize / 2
        let r = cellSize * 0.25

        // Outer glow
        let glowRect = CGRect(x: cx - r * 1.8, y: cy - r * 1.8, width: r * 3.6, height: r * 3.6)
        context.fill(
            Path(ellipseIn: glowRect),
            with: .color(.green.opacity(0.15))
        )

        // Inner circle
        let innerRect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
        context.fill(
            Path(ellipseIn: innerRect),
            with: .color(.green.opacity(0.6))
        )
        context.stroke(
            Path(ellipseIn: innerRect),
            with: .color(.green),
            lineWidth: 1.5
        )
    }
}
