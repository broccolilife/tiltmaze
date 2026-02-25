# 🏐 TiltMaze

A tilt-to-navigate maze game for iPhone. Tilt your phone to roll a glowing ball through procedurally generated mazes. Each level gets harder. How efficient can you be?

## 📸 Screenshots

> Screenshots coming soon — the game requires a physical iPhone (accelerometer doesn't work in Simulator).

| Game View | Win Screen | Progressive Difficulty |
|-----------|------------|----------------------|
| *Neon ball in maze* | *Star rating overlay* | *Larger mazes at higher levels* |

## 🚀 Getting Started

### Prerequisites

- **Xcode 15+** with iOS 17 SDK
- **Physical iPhone** — CoreMotion accelerometer is required (Simulator won't work)
- Apple Developer account (free tier is fine for personal device testing)

### Build & Run

```bash
# Clone the repo
git clone https://github.com/broccolilife/tiltmaze.git
cd tiltmaze

# Option A: XcodeGen (recommended)
brew install xcodegen
xcodegen generate --spec ios-project.yml
open TiltMaze.xcodeproj

# Option B: Manual Xcode project
# Create new iOS App in Xcode (SwiftUI), drag TiltMaze/ folder in
```

1. Open the project in Xcode
2. Select your physical iPhone as the build target
3. Set your **Development Team** under Signing & Capabilities
4. Hit ▶️ Run — tilt your phone and play!

### First Play

- The ball spawns at the **top-left** corner
- Tilt your phone to roll it through the maze
- Reach the **green goal** (opposite corner) to win
- You'll see your **time** and **efficiency** rating (⭐–⭐⭐⭐)
- Tap **Next Level** for a harder maze, or **New Maze** to retry at the same difficulty

## 🏗 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    TiltMazeApp.swift                     │
│                    (App entry point)                     │
└─────────────────┬───────────────────────────────────────┘
                  │
         ┌────────▼────────┐
         │  MazeGameView   │  Main game screen: HUD, win overlay,
         │  (SwiftUI View) │  layout computation, user actions
         └────────┬────────┘
                  │ uses
    ┌─────────────┼─────────────┐
    ▼             ▼             ▼
┌──────────┐ ┌──────────┐ ┌──────────────┐
│ MazeView │ │GameState │ │MazeGenerator │
│ (Canvas) │ │(ObsObj)  │ │ (DFS algo)   │
└──────────┘ └──────────┘ └──────────────┘
  Renders      Physics,      Recursive
  walls &      motion,       backtracking
  ball         collision,    maze creation
               scoring
```

### Data Flow

1. **MazeGenerator** creates a perfect maze using recursive backtracking (DFS). Every maze has exactly one solution path.
2. **GameState** owns the game loop via `CADisplayLink` at 60fps. It reads `CMMotionManager` gravity data, applies acceleration → velocity → position with friction and wall collision.
3. **MazeView** renders the maze walls and ball on a SwiftUI `Canvas` — efficient immediate-mode drawing.
4. **MazeGameView** composes everything: the maze view, HUD (timer, level, efficiency), and win overlay with star ratings.

### Key Algorithms

| Component | Algorithm | Details |
|-----------|-----------|---------|
| Maze Generation | Recursive Backtracking (DFS) | Guarantees exactly one path between any two cells — a "perfect" maze |
| Ball Physics | Euler Integration | Gravity → acceleration → velocity (with friction 0.94) → position, clamped to max speed |
| Collision | Per-Cell Wall Check | Ball edges tested against current cell's walls; X and Y resolved independently for wall-sliding |
| Optimal Path | BFS (Breadth-First Search) | Computes shortest path from start to end for efficiency scoring |
| Difficulty | Progressive Scaling | Maze rows/cols increase with level; future: adaptive based on struggle ratio |

## ✨ Features

- 🎮 **Accelerometer controls** — tilt your phone to move the ball
- 🧩 **Procedural mazes** — recursive backtracking algorithm, unique every time
- 📈 **Progressive difficulty** — mazes grow each level
- ⏱ **Timer + efficiency tracking** — BFS computes optimal path, compares to yours
- 🏆 **Star rating** — ⭐⭐⭐ perfect, ⭐⭐ great, ⭐ good
- 🔄 **New Maze button** — regenerate without advancing level
- ⚡ **60fps physics** — smooth movement with wall collision & sliding
- 🎨 **Neon aesthetic** — dark background, glowing cyan ball, clean white walls
- 📦 **Zero dependencies** — pure SwiftUI + CoreMotion

## 🛠 Tech Stack

| Technology | Purpose |
|-----------|---------|
| **SwiftUI** | Declarative UI and views |
| **Canvas** | Efficient immediate-mode maze wall rendering |
| **CoreMotion** | Accelerometer / gravity input |
| **CADisplayLink** | 60fps game loop tied to display refresh |

No external dependencies. No packages. No pods.

## 🗺 Roadmap

- [ ] Adaptive difficulty — adjust maze size based on player struggle ratio
- [ ] Haptic feedback on wall collisions
- [ ] Level select / saved progress
- [ ] Leaderboard with Game Center

See [TASKS.md](TASKS.md) for the full breakdown.

## 📄 License

MIT
