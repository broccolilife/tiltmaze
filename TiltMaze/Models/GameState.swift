import Foundation
import CoreMotion
import SwiftUI

/// Central game manager: owns the maze, ball physics, motion input, scoring, and win detection.
///
/// Uses `CMMotionManager` for accelerometer data and `CADisplayLink` for a 60fps game loop.
/// Published properties drive SwiftUI view updates reactively.
@MainActor
class GameState: ObservableObject {

    // MARK: - Maze

    @Published var maze: MazeGenerator       // Current maze instance (regenerated each level)
    @Published var ballPos: CGPoint          // Ball center position in screen coordinates (pixels)
    @Published var hasWon: Bool = false       // Triggers win overlay in MazeGameView
    @Published var level: Int = 1            // Current difficulty level (affects maze size)

    // MARK: - Config

    let mazeRows: Int                        // Base maze height (rows increase with level)
    let mazeCols: Int                        // Base maze width (cols increase with level)
    var cellSize: CGFloat = 0                // Computed pixel size of each maze cell
    var mazeOrigin: CGPoint = .zero          // Top-left corner of maze on screen (centered)
    let ballRadius: CGFloat = 6              // Ball collision radius in points

    // MARK: - Tracking

    @Published var elapsedTime: TimeInterval = 0   // Seconds since maze started
    @Published var totalDistance: CGFloat = 0       // Total pixels the ball has traveled
    private var optimalDistance: CGFloat = 0        // BFS-computed shortest path in pixels
    private var startTime: Date = .now
    private var lastBallPos: CGPoint = .zero        // Previous frame's position (for distance calc)

    // MARK: - Physics
    // Tuning constants — adjust these to change game feel

    private var velocity: CGPoint = .zero
    private let maxSpeed: CGFloat = 500      // Hard cap on ball speed (pixels/sec)
    private let friction: CGFloat = 0.94     // Per-frame velocity damping (lower = more drag)
    private let sensitivity: CGFloat = 1000  // Gravity → acceleration multiplier

    // Trail
    @Published var trail: [CGPoint] = []
    private let maxTrailLength = 25

    // MARK: - Motion

    private let motionManager = CMMotionManager()
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0

    init(rows: Int = 10, cols: Int = 7) {
        self.mazeRows = rows
        self.mazeCols = cols
        let maze = MazeGenerator(rows: rows, cols: cols, startRow: 0, startCol: 0)
        self.maze = maze
        self.ballPos = .zero
    }

    // MARK: - Layout

    func configure(screenSize: CGSize) {
        let padding: CGFloat = 20
        let availableWidth = screenSize.width - padding * 2
        let availableHeight = screenSize.height - padding * 2

        cellSize = min(availableWidth / CGFloat(mazeCols), availableHeight / CGFloat(mazeRows))
        let mazeWidth = cellSize * CGFloat(mazeCols)
        let mazeHeight = cellSize * CGFloat(mazeRows)
        mazeOrigin = CGPoint(
            x: (screenSize.width - mazeWidth) / 2,
            y: (screenSize.height - mazeHeight) / 2
        )

        // Place ball at start cell center
        ballPos = cellCenter(row: maze.start.row, col: maze.start.col)
        lastBallPos = ballPos

        // Calculate optimal path distance (BFS)
        optimalDistance = computeOptimalDistance()

        // Reset tracking
        totalDistance = 0
        elapsedTime = 0
        startTime = .now
        trail = []
    }

    func cellCenter(row: Int, col: Int) -> CGPoint {
        CGPoint(
            x: mazeOrigin.x + CGFloat(col) * cellSize + cellSize / 2,
            y: mazeOrigin.y + CGFloat(row) * cellSize + cellSize / 2
        )
    }

    // MARK: - Motion Control

    func startMotion() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates()

        displayLink = CADisplayLink(target: DisplayLinkTarget { [weak self] dt in
            Task { @MainActor in
                self?.update(dt: dt)
            }
        }, selector: #selector(DisplayLinkTarget.tick(_:)))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120)
        displayLink?.add(to: .main, forMode: .common)
    }

    func stopMotion() {
        motionManager.stopDeviceMotionUpdates()
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: - Physics Update

    /// Core physics update — called every frame (~60fps) by CADisplayLink.
    /// Reads device gravity → computes acceleration → integrates velocity → moves ball with collision.
    private func update(dt: CGFloat) {
        guard !hasWon, let motion = motionManager.deviceMotion else { return }

        // Device gravity gives tilt direction (range -1 to 1 per axis).
        // X maps directly; Y is inverted because screen Y grows downward.
        let ax = CGFloat(motion.gravity.x) * sensitivity
        let ay = CGFloat(-motion.gravity.y) * sensitivity  // invert Y for screen coords

        velocity.x = (velocity.x + ax * dt) * friction
        velocity.y = (velocity.y + ay * dt) * friction

        // Clamp speed
        let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        if speed > maxSpeed {
            velocity.x = velocity.x / speed * maxSpeed
            velocity.y = velocity.y / speed * maxSpeed
        }

        // Move with collision
        let newX = ballPos.x + velocity.x * dt
        let newY = ballPos.y + velocity.y * dt

        // Resolve X and Y movement independently — this enables "wall sliding"
        // where the ball slides along a wall instead of stopping dead.
        let afterX = CGPoint(x: newX, y: ballPos.y)
        if !collides(at: afterX) {
            ballPos.x = newX
        } else {
            velocity.x = 0
        }

        let afterY = CGPoint(x: ballPos.x, y: newY)
        if !collides(at: afterY) {
            ballPos.y = newY
        } else {
            velocity.y = 0
        }

        // Track distance traveled
        let dx = ballPos.x - lastBallPos.x
        let dy = ballPos.y - lastBallPos.y
        let moved = sqrt(dx * dx + dy * dy)
        totalDistance += moved
        lastBallPos = ballPos

        // Update trail
        if moved > 0.5 {
            trail.append(ballPos)
            if trail.count > maxTrailLength {
                trail.removeFirst(trail.count - maxTrailLength)
            }
        }
        elapsedTime = Date.now.timeIntervalSince(startTime)

        // Win check
        let endCenter = cellCenter(row: maze.end.row, col: maze.end.col)
        let dist = sqrt(pow(ballPos.x - endCenter.x, 2) + pow(ballPos.y - endCenter.y, 2))
        if dist < cellSize * 0.3 {
            hasWon = true
            elapsedTime = Date.now.timeIntervalSince(startTime)
            stopMotion()
        }
    }

    // MARK: - Collision Detection

    private func collides(at pos: CGPoint) -> Bool {
        // Check ball edges against maze walls
        let r = ballRadius

        // Which cell is the ball in?
        let col = Int((pos.x - mazeOrigin.x) / cellSize)
        let row = Int((pos.y - mazeOrigin.y) / cellSize)

        // Out of bounds = collision
        if row < 0 || row >= mazeRows || col < 0 || col >= mazeCols { return true }

        let cell = maze.grid[row][col]
        let cellX = mazeOrigin.x + CGFloat(col) * cellSize
        let cellY = mazeOrigin.y + CGFloat(row) * cellSize

        // Check each wall
        if cell.top    && pos.y - r < cellY              { return true }
        if cell.bottom && pos.y + r > cellY + cellSize    { return true }
        if cell.left   && pos.x - r < cellX              { return true }
        if cell.right  && pos.x + r > cellX + cellSize    { return true }

        return false
    }

    // MARK: - Difficulty & Scoring

    /// How much the player struggled: 1.0 = perfect, higher = more struggle
    var struggleRatio: CGFloat {
        guard optimalDistance > 0 else { return 1.0 }
        return totalDistance / optimalDistance
    }

    var formattedTime: String {
        let t = Int(elapsedTime)
        return String(format: "%d:%02d", t / 60, t % 60)
    }

    /// Compute optimal path length in pixels using BFS
    private func computeOptimalDistance() -> CGFloat {
        let rows = maze.rows
        let cols = maze.cols
        var visited = Array(repeating: Array(repeating: false, count: cols), count: rows)
        var parent: [Int: Int] = [:]  // flattened index -> parent index
        let startIdx = maze.start.row * cols + maze.start.col
        let endIdx = maze.end.row * cols + maze.end.col

        var queue = [startIdx]
        visited[maze.start.row][maze.start.col] = true

        while !queue.isEmpty {
            let curr = queue.removeFirst()
            let r = curr / cols
            let c = curr % cols

            if curr == endIdx { break }

            let cell = maze.grid[r][c]
            let neighbors: [(Int, Int, Bool)] = [
                (r-1, c, !cell.top),
                (r+1, c, !cell.bottom),
                (r, c-1, !cell.left),
                (r, c+1, !cell.right),
            ]

            for (nr, nc, open) in neighbors {
                guard open, nr >= 0, nr < rows, nc >= 0, nc < cols, !visited[nr][nc] else { continue }
                visited[nr][nc] = true
                let nIdx = nr * cols + nc
                parent[nIdx] = curr
                queue.append(nIdx)
            }
        }

        // Trace path length
        var pathLen = 0
        var idx = endIdx
        while idx != startIdx {
            guard let p = parent[idx] else { return CGFloat(rows + cols) * cellSize }
            pathLen += 1
            idx = p
        }
        return CGFloat(pathLen) * cellSize
    }

    // MARK: - New Game

    func newGame() {
        level += 1
        // Future: use struggleRatio to adjust difficulty
        let extraRows = min(level / 3, 10)
        let extraCols = min(level / 4, 5)
        let rows = mazeRows + extraRows
        let cols = mazeCols + extraCols
        maze = MazeGenerator(rows: rows, cols: cols, startRow: 0, startCol: 0)
        hasWon = false
        velocity = .zero
    }

    /// Reset current maze (new maze button)
    func resetMaze() {
        maze = MazeGenerator(rows: maze.rows, cols: maze.cols, startRow: maze.start.row, startCol: maze.start.col)
        hasWon = false
        velocity = .zero
    }
}

// MARK: - CADisplayLink helper (non-isolated target)

private class DisplayLinkTarget {
    let callback: (CGFloat) -> Void
    private var lastTimestamp: CFTimeInterval = 0

    init(callback: @escaping (CGFloat) -> Void) {
        self.callback = callback
    }

    @objc func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 { lastTimestamp = link.timestamp }
        let dt = CGFloat(link.timestamp - lastTimestamp)
        lastTimestamp = link.timestamp
        if dt > 0 && dt < 0.1 {
            callback(dt)
        }
    }
}
