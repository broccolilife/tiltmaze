# 🏐 TiltMaze

A tilt-to-navigate maze game for iPhone. Tilt your phone to roll a ball through procedurally generated mazes.

## Features

- 🎮 **Accelerometer controls** — tilt your phone to move the ball
- 🧩 **Procedural mazes** — unique maze every time (recursive backtracking)
- 📈 **Progressive difficulty** — mazes get bigger each level
- ⚡ **60fps physics** — smooth ball movement with wall sliding
- 🎨 **Minimal neon aesthetic** — dark background, glowing ball, clean walls

## How to Play

1. The ball starts at the top-left
2. Tilt your phone to roll toward the green goal
3. Reach the goal to advance to the next level
4. Mazes grow larger as you progress

## Build

```bash
# Using XcodeGen
brew install xcodegen
cd tiltmaze
xcodegen generate --spec ios-project.yml
open TiltMaze.xcodeproj

# Or manually: create iOS App project in Xcode, drag TiltMaze/ folder in
```

> ⚠️ Must run on a **physical iPhone** — the accelerometer doesn't work in the Simulator.

## Structure

```
TiltMaze/
├── TiltMazeApp.swift              # App entry point
├── Models/
│   ├── MazeGenerator.swift        # Recursive backtracking maze gen
│   └── GameState.swift            # Physics, motion, collision, win detection
└── Views/
    ├── MazeGameView.swift         # Main game screen
    └── MazeView.swift             # Canvas-based maze wall renderer
```

## Tech

- SwiftUI + Canvas for rendering
- CoreMotion for accelerometer input
- CADisplayLink for 60fps game loop
- No external dependencies
