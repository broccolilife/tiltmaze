# 🏐 TiltMaze

A tilt-to-navigate maze game for iPhone. Tilt your phone to roll a glowing ball through procedurally generated mazes. Each level gets harder. How efficient can you be?

## The Idea

Simple concept, satisfying execution:
1. A maze is generated on screen. The ball always starts at its position.
2. You tilt your phone to roll the ball through the maze.
3. Reach the green goal to win. Or tap "New Maze" for a fresh one.
4. The game tracks your **time** and **efficiency** — how close your path was to the optimal route.
5. Levels progressively increase in maze complexity.

**Future:** Adaptive difficulty — the game watches how you play (time + struggle vs. optimal path) and calibrates the next maze accordingly. Struggled? Easier maze. Crushed it? Harder.

## Demo

> ⚠️ Requires a **physical iPhone** — accelerometer doesn't work in Simulator.

## Features

- 🎮 **Accelerometer controls** — tilt your phone to move the ball
- 🧩 **Procedural mazes** — recursive backtracking algorithm, unique every time
- 📈 **Progressive difficulty** — mazes grow each level
- ⏱ **Timer + efficiency tracking** — BFS computes optimal path, compares to yours
- 🏆 **Star rating** — ⭐⭐⭐ perfect, ⭐⭐ great, ⭐ good
- 🔄 **New Maze button** — regenerate without advancing level
- ⚡ **60fps physics** — smooth movement with wall collision & sliding
- 🎨 **Neon aesthetic** — dark background, glowing cyan ball, clean white walls
- 📦 **Zero dependencies** — pure SwiftUI + CoreMotion

## Architecture

```
TiltMaze/
├── TiltMazeApp.swift              # App entry point
├── Models/
│   ├── MazeGenerator.swift        # Recursive backtracking maze generation
│   └── GameState.swift            # Physics, motion, collision, BFS, scoring
└── Views/
    ├── MazeGameView.swift         # Main game UI + HUD + win overlay
    └── MazeView.swift             # Canvas-based maze wall renderer
```

### How It Works

| Component | Details |
|-----------|---------|
| **Maze Generation** | Recursive backtracking (DFS) on a grid. Guarantees exactly one path between any two cells. |
| **Ball Physics** | CoreMotion reads device gravity → applied as acceleration → velocity with friction → position update at 60fps via CADisplayLink. |
| **Collision** | Ball checks its edges against the walls of its current cell. X and Y resolved independently for wall-sliding. |
| **Optimal Path** | BFS from start to end computes shortest path distance in cells × cellSize. |
| **Struggle Ratio** | `totalDistanceTraveled / optimalDistance`. Lower = more efficient. |
| **Difficulty** | Maze rows/cols increase with level. Future: adaptive based on struggle ratio. |

## Build & Run

```bash
# Option A: XcodeGen
brew install xcodegen
cd tiltmaze
xcodegen generate --spec ios-project.yml
open TiltMaze.xcodeproj

# Option B: Manual
# Create new iOS App in Xcode (SwiftUI), drag TiltMaze/ folder in
```

Set your Development Team in Signing & Capabilities, then run on a physical iPhone.

## Tech

- **SwiftUI** — UI and views
- **Canvas** — efficient maze wall rendering
- **CoreMotion** — accelerometer input
- **CADisplayLink** — 60fps game loop
- No external dependencies. No packages. No pods.

## Roadmap

See [TASKS.md](TASKS.md) for the full breakdown of work items, organized for LLM coding agents.

## License

MIT
