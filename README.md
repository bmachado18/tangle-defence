# 🎮 Tangle Defense – Game Design Document

## 📌 Game Title *(Working Title)*
**Tangle Defense**

## 🧠 High Concept
*Tangle Defense* is a strategic tower defense game where players place nodes and connect them with ropes (edges) to block or slow enemies traveling along a central path. The strength of each rope is determined by its length and the number of times it crosses other ropes. Players must carefully design efficient, untangled webs to hold off increasingly strong waves of enemies.

## 🎯 Core Gameplay Loop
1. **Prep Phase**: Place nodes and draw edges between them.
2. **Sim Phase**: Enemies spawn and move along the set path.
3. **Collision Phase**: Edges attempt to block or delay enemies based on calculated strength.
4. **Evaluate & Repeat**: After a finite number of waves, the game ends with either victory or failure.

## 🧱 Core Mechanics

### Node Placement
- Players place a **fixed number of nodes** each round before the wave starts.
- Nodes can be placed only in designated areas.

### Edge (Rope) Creation
- Players draw edges between two placed nodes.
- Each edge has:
  - **Strength** calculated as:

	```
	strength = base / ((1 + k * distance) * (1 + c * crossings))
	```

	- `distance`: Euclidean distance between nodes
	- `crossings`: number of edges that intersect this edge
	- `k`, `c`: tunable constants

### Enemy Waves
- Enemies spawn in timed intervals and travel along a **fixed path**.
- Each enemy has:
  - `strength` (used to break edges)
  - `speed`
- Enemies interact with edges:
  - If `enemy.strength > edge.strength`: edge breaks
  - If `enemy.strength <= edge.strength`: enemy is slowed or stopped

## 🕹 Controls

| Action                  | Input            |
|-------------------------|------------------|
| Place Node              | Left Click       |
| Select Node             | Left Click       |
| Draw Edge (Node to Node)| Click → Click    |
| Start Round             | UI Button        |

## 📐 UI Elements
- Round Counter
- Enemy Counter
- Edge Strength Display (on hover or selection)
- Start Wave Button

## 🎨 Visual Style
- 2D Top-down
- Clean, abstract aesthetic (thread, wireframe, minimalist)
- Color-coded ropes:
  - **Green** = strong
  - **Yellow** = medium
  - **Red** = weak or tangled

## 🧪 MVP Scope

### Must Have
- [x] Node placement
- [x] Edge creation and removal
- [x] Rope strength calculation (distance + crossings)
- [x] Basic enemy movement along fixed path
- [x] Collision logic between enemy and edge
- [x] Multiple waves of enemies
- [x] Visual indicators of edge strength

### Nice to Have
- [ ] Undo rope placement
- [ ] Rope snapping animation/sound
- [ ] Dynamic enemy types (fast/weak vs slow/strong)
- [ ] Edge repair or cooldown regen
- [ ] Grid snapping for precise node placement

## 🧠 Strategic Depth
Players must balance:
- Short, strong ropes vs wide coverage
- Avoiding rope crossings for max strength
- Limited number of nodes or rope length
- Emergent gameplay from creative "web" designs

## ⚔️ Win / Lose Conditions
- **Win**: Survive all enemy waves without letting too many escape
- **Lose**: A set number of enemies (e.g., 10) reach the end

## 🔧 Tech Stack
- **Engine**: Godot (4.x or 3.x)
- **Language**: GDScript
- **Target Platform**: Desktop (HTML5 optional)
- **Resolution**: 1280x720 (scalable)

## 🧩 Stretch Goals
- Enemies that create crossings as they pass
- Rope upgrades (e.g., braid ropes to reduce crossing penalty)
- Multiple level shapes and path layouts
- Procedural path generation
- Multiplayer cooperative tangle building
