import Foundation

/// Cell walls represented as a bitmask
struct Cell {
    var top: Bool = true
    var bottom: Bool = true
    var left: Bool = true
    var right: Bool = true
}

/// Generates a perfect maze using recursive backtracking (DFS).
/// Guarantees exactly one path from start to end.
class MazeGenerator {
    let rows: Int
    let cols: Int
    var grid: [[Cell]]

    /// Start and end positions
    let start: (row: Int, col: Int)
    let end: (row: Int, col: Int)

    init(rows: Int, cols: Int, startRow: Int, startCol: Int) {
        self.rows = rows
        self.cols = cols
        self.start = (startRow, startCol)

        // Place end as far as possible from start
        self.end = MazeGenerator.farthestCorner(from: (startRow, startCol), rows: rows, cols: cols)

        // Initialize grid with all walls
        self.grid = Array(repeating: Array(repeating: Cell(), count: cols), count: rows)

        generate()
    }

    /// Pick the corner farthest from start
    private static func farthestCorner(from start: (Int, Int), rows: Int, cols: Int) -> (Int, Int) {
        let corners = [(0, 0), (0, cols - 1), (rows - 1, 0), (rows - 1, cols - 1)]
        var best = corners[0]
        var bestDist = 0
        for c in corners {
            let dist = abs(c.0 - start.0) + abs(c.1 - start.1)
            if dist > bestDist {
                bestDist = dist
                best = c
            }
        }
        return best
    }

    /// Recursive backtracking maze generation
    private func generate() {
        var visited = Array(repeating: Array(repeating: false, count: cols), count: rows)
        var stack: [(Int, Int)] = [(start.row, start.col)]
        visited[start.row][start.col] = true

        while !stack.isEmpty {
            let (r, c) = stack.last!
            let neighbors = unvisitedNeighbors(r, c, visited: visited)

            if neighbors.isEmpty {
                stack.removeLast()
            } else {
                let (nr, nc) = neighbors.randomElement()!
                removeWall(r, c, nr, nc)
                visited[nr][nc] = true
                stack.append((nr, nc))
            }
        }
    }

    private func unvisitedNeighbors(_ r: Int, _ c: Int, visited: [[Bool]]) -> [(Int, Int)] {
        var result: [(Int, Int)] = []
        if r > 0 && !visited[r-1][c] { result.append((r-1, c)) }
        if r < rows-1 && !visited[r+1][c] { result.append((r+1, c)) }
        if c > 0 && !visited[r][c-1] { result.append((r, c-1)) }
        if c < cols-1 && !visited[r][c+1] { result.append((r, c+1)) }
        return result
    }

    private func removeWall(_ r1: Int, _ c1: Int, _ r2: Int, _ c2: Int) {
        if r2 == r1 - 1 { // neighbor is above
            grid[r1][c1].top = false
            grid[r2][c2].bottom = false
        } else if r2 == r1 + 1 { // neighbor is below
            grid[r1][c1].bottom = false
            grid[r2][c2].top = false
        } else if c2 == c1 - 1 { // neighbor is left
            grid[r1][c1].left = false
            grid[r2][c2].right = false
        } else if c2 == c1 + 1 { // neighbor is right
            grid[r1][c1].right = false
            grid[r2][c2].left = false
        }
    }
}
