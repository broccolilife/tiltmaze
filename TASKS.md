# TASKS.md — Agent Work Breakdown

Step-by-step tasks for LLM coding agents (Claude Code, Codex, Antigravity, etc.) to improve TiltMaze. Each task is self-contained with clear inputs, outputs, and acceptance criteria.

---

## Phase 1: Core Polish (Priority: High)

### Task 1.1 — Adaptive Difficulty System
**File:** `GameState.swift`
**Branch:** `feat/adaptive-difficulty`

Wire up the `struggleRatio` to dynamically adjust the next maze:
- If `struggleRatio < 1.5` AND `elapsedTime < 20s` → increase rows+cols by 2
- If `struggleRatio > 3.0` OR `elapsedTime > 90s` → keep same size or reduce by 1
- Otherwise → increase by 1 (current behavior)
- Store a `difficultyLevel` (1-10) that tracks overall progression
- Add unit tests for difficulty calculation logic

**Acceptance:** Difficulty visibly adapts to player skill. Fast/efficient players get harder mazes. Struggling players don't get punished.

---

### Task 1.2 — Haptic Feedback
**File:** `GameState.swift`
**Branch:** `feat/haptics`

Add haptic feedback using `UIImpactFeedbackGenerator`:
- Light tap when ball hits a wall
- Medium tap on "New Maze" press
- Success notification haptic on level complete
- Throttle wall haptics to max 1 per 0.1s (avoid buzzing)

**Acceptance:** Haptics feel satisfying, not overwhelming. Wall bounces feel tactile.

---

### Task 1.3 — Sound Effects
**Files:** New `Audio/` folder + `GameState.swift`
**Branch:** `feat/audio`

Add minimal sound effects using `AVAudioPlayer`:
- Ball rolling ambient sound (loops while moving, stops when idle)
- Wall bump sound (short, soft)
- Level complete chime
- Add a mute toggle in the HUD
- Use royalty-free sounds or generate with `AVAudioEngine` synthesis

**Acceptance:** Sounds enhance the experience. Mute toggle works. No lag on playback.

---

## Phase 2: Visual Upgrade (Priority: Medium)

### Task 2.1 — Ball Trail Effect
**File:** `MazeGameView.swift`
**Branch:** `feat/ball-trail`

Add a fading trail behind the ball:
- Store last N positions (e.g., 20)
- Render as circles with decreasing opacity and size
- Color gradient from cyan to transparent
- Trail should NOT persist across maze resets

**Acceptance:** Trail looks smooth and performant. No frame drops.

---

### Task 2.2 — Maze Reveal Animation
**Files:** `MazeView.swift`, `MazeGameView.swift`
**Branch:** `feat/maze-animation`

Animate maze appearance when a new maze is generated:
- Walls draw in from the start cell outward (radial reveal)
- Animation duration: ~0.8s
- Ball appears after animation completes
- Use `withAnimation` or manual `Canvas` animation

**Acceptance:** Maze doesn't just pop in — it has a satisfying reveal. Ball waits for reveal to finish.

---

### Task 2.3 — Dark/Neon Theme System
**Files:** New `Theme.swift` + all Views
**Branch:** `feat/themes`

Create a theme system with 3 presets:
- **Neon** (current): black bg, white walls, cyan ball
- **Retro**: dark green bg, bright green walls, white ball (Game Boy style)
- **Minimal**: white bg, gray walls, black ball

Store selected theme in `UserDefaults`. Add theme picker in a settings sheet.

**Acceptance:** All 3 themes render correctly. Selection persists across launches.

---

## Phase 3: Gameplay Features (Priority: Medium)

### Task 3.1 — Fog of War / Limited Visibility
**Files:** `MazeView.swift`, `GameState.swift`
**Branch:** `feat/fog-of-war`

Add an optional mode where only nearby cells are visible:
- Render a radial gradient mask centered on the ball
- Visible radius: 2-3 cells
- Visited cells remain slightly visible (dimmed)
- Toggle in settings or unlock at level 5+

**Acceptance:** Creates tension and exploration feel. Visited paths stay dimly lit.

---

### Task 3.2 — Collectibles / Coins
**Files:** `GameState.swift`, `MazeGameView.swift`
**Branch:** `feat/collectibles`

Scatter collectible items in the maze:
- Place 3-5 coins in random dead-end cells
- Ball picks up coin when passing through (auto-collect)
- Display coin count in HUD
- Bonus: collecting all coins before reaching goal = bonus star

**Acceptance:** Coins render in maze. Collection works. Count shows in HUD and win screen.

---

### Task 3.3 — Leaderboard / Personal Best
**Files:** New `LeaderboardView.swift`, `GameState.swift`
**Branch:** `feat/leaderboard`

Track personal bests per level:
- Store best time and best efficiency for each level in `UserDefaults`
- Show personal best on win screen (with "New Record!" indicator)
- Add a leaderboard view accessible from HUD
- Sort by level, show time + efficiency + star rating

**Acceptance:** Records persist. New records are highlighted. Leaderboard view is scrollable.

---

## Phase 4: Advanced (Priority: Low)

### Task 4.1 — Multiplayer Race (Local)
**Branch:** `feat/multiplayer`

Two players on same WiFi race through identical mazes:
- Use `MultipeerConnectivity` framework
- Both devices generate same maze (shared seed)
- Show opponent's ball position as a ghost (semi-transparent)
- First to reach goal wins

**Acceptance:** Two iPhones connect, see each other's ball, race works.

---

### Task 4.2 — Maze Editor
**Branch:** `feat/editor`

Let users create custom mazes:
- Tap cells to toggle walls
- Set start/end positions
- Validate maze is solvable (BFS check)
- Save/load custom mazes
- Share via URL scheme or clipboard

**Acceptance:** Editor creates valid mazes. Save/load works. Invalid mazes show error.

---

### Task 4.3 — watchOS Companion
**Branch:** `feat/watchos`

Minimal Apple Watch version:
- Smaller grid (5x5)
- Use Digital Crown to control direction (rotate to steer)
- Or wrist tilt if accelerometer available
- Show level + time on watch face complication

**Acceptance:** Game runs on Apple Watch. Controls feel usable on small screen.

---

## Agent Instructions

### For any task:
1. Create the specified branch from `main`
2. Read existing code to understand patterns and conventions
3. Implement the feature following existing SwiftUI + GameState patterns
4. Keep zero external dependencies
5. Test on physical iPhone where applicable (accelerometer features)
6. Commit with descriptive message: `feat: <description>`
7. Open a PR to `main` with a summary of changes

### Parallel work:
These tasks can be worked on simultaneously by different agents:
- **Agent A:** Phase 1 (1.1 → 1.2 → 1.3) — sequential, they build on each other
- **Agent B:** Phase 2 (2.1, 2.2, 2.3) — independent, can be done in any order
- **Agent C:** Phase 3 (3.1, 3.2, 3.3) — independent, can be done in any order
- **Agent D:** Phase 4 — only after Phase 1-2 merge

### Code style:
- SwiftUI views, `@StateObject` / `@Published` for state
- `@MainActor` on observable classes
- Canvas for performance-critical rendering
- No UIKit unless absolutely necessary
- Comments on non-obvious logic
