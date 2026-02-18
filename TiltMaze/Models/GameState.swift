import Foundation
import CoreMotion
import SwiftUI

/// Manages ball physics, motion input, and win detection.
@MainActor
class GameState: ObservableObject {

    // MARK: - Maze

    @Published var maze: MazeGenerator
    @Published var ballPos: CGPoint       // pixel position of ball center
    @Published var hasWon: Bool = false
    @Published var level: Int = 1

    // MARK: - Config

    let mazeRows: Int
    let mazeCols: Int
    var cellSize: CGFloat = 0
    var mazeOrigin: CGPoint = .zero
    let ballRadius: CGFloat = 6

    // MARK: - Physics

    private var velocity: CGPoint = .zero
    private let maxSpeed: CGFloat = 300
    private let friction: CGFloat = 0.92
    private let sensitivity: CGFloat = 600

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

    private func update(dt: CGFloat) {
        guard !hasWon, let motion = motionManager.deviceMotion else { return }

        // Gravity from device attitude (phone held portrait, tilted)
        let ax = CGFloat(motion.gravity.x) * sensitivity
        let ay = CGFloat(-motion.gravity.y) * sensitivity  // invert Y

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

        // Try X then Y separately for wall sliding
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

        // Win check
        let endCenter = cellCenter(row: maze.end.row, col: maze.end.col)
        let dist = sqrt(pow(ballPos.x - endCenter.x, 2) + pow(ballPos.y - endCenter.y, 2))
        if dist < cellSize * 0.3 {
            hasWon = true
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

    // MARK: - New Game

    func newGame() {
        level += 1
        let extraRows = min(level / 3, 10)
        let extraCols = min(level / 4, 5)
        let rows = mazeRows + extraRows
        let cols = mazeCols + extraCols
        maze = MazeGenerator(rows: rows, cols: cols, startRow: 0, startCol: 0)
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
