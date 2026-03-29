import Foundation
import SwiftUI

/// Records and replays ghost paths — race your best time on any maze.
/// Stores position snapshots at fixed intervals and replays them as a translucent ghost ball.
@MainActor
class GhostReplay: ObservableObject {

    // MARK: - Types

    struct Snapshot: Codable {
        let x: Double
        let y: Double
        let t: TimeInterval  // seconds since run start
    }

    struct GhostRun: Codable {
        let mazeHash: String
        let level: Int
        let time: TimeInterval
        let snapshots: [Snapshot]
    }

    // MARK: - State

    @Published var ghostPosition: CGPoint? = nil
    @Published var isRecording: Bool = false
    @Published var hasGhost: Bool = false

    private var currentSnapshots: [Snapshot] = []
    private var recordStart: Date = .now
    private var bestRun: GhostRun? = nil
    private var playbackIndex: Int = 0
    private var playbackStart: Date = .now

    private let recordInterval: TimeInterval = 1.0 / 30.0  // 30 fps recording
    private var lastRecordTime: TimeInterval = 0

    // MARK: - Recording

    func startRecording(mazeHash: String) {
        isRecording = true
        currentSnapshots = []
        recordStart = .now
        lastRecordTime = 0
    }

    func recordPosition(_ pos: CGPoint, elapsed: TimeInterval) {
        guard isRecording else { return }
        guard elapsed - lastRecordTime >= recordInterval else { return }
        lastRecordTime = elapsed

        currentSnapshots.append(Snapshot(
            x: Double(pos.x),
            y: Double(pos.y),
            t: elapsed
        ))
    }

    func finishRecording(mazeHash: String, level: Int, time: TimeInterval) {
        isRecording = false
        guard !currentSnapshots.isEmpty else { return }

        let run = GhostRun(
            mazeHash: mazeHash,
            level: level,
            time: time,
            snapshots: currentSnapshots
        )

        // Save if it's the best (or only) run for this maze
        if let existing = bestRun, existing.mazeHash == mazeHash {
            if time < existing.time {
                bestRun = run
                save(run)
            }
        } else {
            bestRun = run
            save(run)
        }
    }

    // MARK: - Playback

    func startPlayback(mazeHash: String) {
        guard let run = loadBest(mazeHash: mazeHash) else {
            hasGhost = false
            return
        }
        bestRun = run
        hasGhost = true
        playbackIndex = 0
        playbackStart = .now
        ghostPosition = run.snapshots.first.map { CGPoint(x: $0.x, y: $0.y) }
    }

    func updatePlayback() {
        guard hasGhost, let run = bestRun else { return }
        let elapsed = Date.now.timeIntervalSince(playbackStart)

        // Find the snapshot closest to current elapsed time
        while playbackIndex < run.snapshots.count - 1 &&
              run.snapshots[playbackIndex + 1].t <= elapsed {
            playbackIndex += 1
        }

        if playbackIndex >= run.snapshots.count - 1 {
            // Ghost finished — loop or stop
            ghostPosition = nil
            return
        }

        // Interpolate between current and next snapshot
        let curr = run.snapshots[playbackIndex]
        let next = run.snapshots[playbackIndex + 1]
        let segmentDuration = next.t - curr.t
        guard segmentDuration > 0 else {
            ghostPosition = CGPoint(x: curr.x, y: curr.y)
            return
        }

        let progress = (elapsed - curr.t) / segmentDuration
        let clampedProgress = min(max(progress, 0), 1)

        ghostPosition = CGPoint(
            x: curr.x + (next.x - curr.x) * clampedProgress,
            y: curr.y + (next.y - curr.y) * clampedProgress
        )
    }

    func stopPlayback() {
        hasGhost = false
        ghostPosition = nil
    }

    // MARK: - Persistence (UserDefaults for simplicity)

    private func storageKey(_ hash: String) -> String { "ghost_\(hash)" }

    private func save(_ run: GhostRun) {
        guard let data = try? JSONEncoder().encode(run) else { return }
        UserDefaults.standard.set(data, forKey: storageKey(run.mazeHash))
    }

    func loadBest(mazeHash: String) -> GhostRun? {
        guard let data = UserDefaults.standard.data(forKey: storageKey(mazeHash)) else { return nil }
        return try? JSONDecoder().decode(GhostRun.self, from: data)
    }

    /// Generate a deterministic hash for a maze configuration
    static func mazeHash(rows: Int, cols: Int, level: Int, seed: Int) -> String {
        "\(rows)x\(cols)_L\(level)_S\(seed)"
    }
}
