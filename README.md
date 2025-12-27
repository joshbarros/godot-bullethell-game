# 🎮 Bullet Hell Game

A fast-paced top-down bullet hell shooter built with Godot 4.5.1. Survive waves of enemies, collect power-ups, and aim for the highest time!

![Game Status](https://img.shields.io/badge/Status-Course%20Completed-brightgreen)
![Engine](https://img.shields.io/badge/Engine-Godot%204.5.1-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 🎯 Features

### Core Gameplay
- **Smooth player movement** with WASD controls and lerp-based acceleration/braking
- **Mouse-aimed shooting** with automatic fire and object pooling
- **Enemy AI** with player tracking, local avoidance, and shooting patterns
- **Boss variants** with increased health and larger bullets (10:1 spawn ratio)
- **Power-up system** with 3 potion types:
  - 🟢 Health restoration (+20 HP)
  - 🔵 Increased fire rate and bullet speed
  - 🟡 Movement speed boost

### Polish & Game Feel
- **Camera shake** on player damage for impact feedback
- **Damage flash effects** (red for player, black for enemies)
- **Health bars** for all entities with visual feedback
- **Wobble animations** during movement for dynamic feel
- **Complete audio system** with SFX and looping background music
- **Main menu** with centered UI and scene transitions
- **Game over screen** with time survived and retry functionality

### Technical Features
- **Object pooling** for bullets and enemies (performance optimization)
- **Weighted random spawner** for enemy variety
- **Collision layer system** preventing friendly fire
- **Pause system** with proper process mode configuration
- **Safe node references** with is_instance_valid() checks
- **External TileSet** preventing scene corruption

## 🎮 Controls

| Action | Key/Button |
|--------|-----------|
| Move | WASD |
| Aim | Mouse |
| Shoot | Left Mouse Button (Hold) |
| Pause | ESC (during gameplay) |

## 🚀 Getting Started

### Prerequisites
- Godot 4.5.1 or later
- Git (for cloning the repository)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/joshbarros/godot-bullethell-game.git
cd godot-bullethell-game
```

2. Open the project in Godot:
   - Launch Godot Engine
   - Click "Import"
   - Navigate to the project folder
   - Select `project.godot`
   - Click "Import & Edit"

3. Run the game:
   - Press F5 or click the "Play" button
   - Alternatively, press F6 to run the current scene

## 🎨 Project Structure

```
bullet-hell/
├── Audio/              # Sound effects and music
│   ├── DrinkPotion.wav
│   ├── EnemyDamaged.wav
│   ├── Music.wav
│   ├── PlayerAttack.wav
│   └── PlayerDamaged.wav
├── Scenes/             # Game scenes and prefabs
│   ├── main.tscn      # Main game scene
│   ├── menu.tscn      # Main menu
│   ├── player.tscn
│   ├── enemy.tscn
│   ├── boss_enemy.tscn
│   ├── bullet.tscn
│   └── potion variants/
├── Scripts/            # GDScript files
│   ├── player.gd
│   ├── enemy.gd
│   ├── bullet.gd
│   ├── node_pool.gd   # Object pooling system
│   ├── enemy_spawner.gd
│   ├── potion_spawner.gd
│   ├── game_manager.gd
│   ├── camera_controller.gd
│   └── menu.gd
├── Sprites/            # Sprite sheets and textures
├── Tiles/              # TileMap and TileSet resources
├── ROADMAP.md          # Development roadmap
├── STEAM.MD            # Steam release planning
└── README.md           # This file
```

## 📊 Development Progress

### Completed (December 26, 2025)
- ✅ Core gameplay loop functional
- ✅ Enemy AI and spawning system
- ✅ Power-up system with 3 potion types
- ✅ Audio system (SFX + music)
- ✅ Game over and retry functionality
- ✅ Main menu implementation
- ✅ Camera effects (shake, smooth follow)
- ✅ Object pooling for performance
- ✅ Collision system with proper layers

### Next Steps (See [ROADMAP.md](ROADMAP.md))
- 🎯 Phase 1: Core bullet hell mechanics
  - Visible player hitbox
  - Dodge roll with i-frames
  - Improved bullet patterns
- ✨ Phase 2: Visual polish
  - Particle effects
  - Screen shake enhancements
  - Trail effects
- 🎮 Phase 3: Gamepad support (twin-stick shooter mode)
- 🚀 Phase 4: Steam release preparation

## 🛠️ Built With

- **Engine:** Godot 4.5.1
- **Language:** GDScript
- **Art:** Custom pixel art sprite sheet
- **Audio:** WAV format sound effects

## 📈 Git History

**11 commits on December 26th, 2025:**
1. Initial TileMap recovery and camera fix
2. Cleanup of corrupted backup files
3. TileSet refactor to external file
4. Health bars, wobble animations, damage flash
5. Collision layers, boss variant, weighted spawner
6. Boundary fixes with RectangleShape2D
7. Potion system with 3 pickup types
8. Game manager with pause/retry system
9. Camera shake on damage
10. Complete audio system
11. Main menu - Course completed! 🎉

## 🤝 Contributing

This is a learning project following a Godot course, but suggestions and feedback are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Godot Engine community for excellent documentation
- Course instructor for structured learning path
- AI assistance (ChatGPT) for debugging and best practices

## 📞 Contact

**Josue Barros**
- GitHub: [@joshbarros](https://github.com/joshbarros)
- Project Link: [https://github.com/joshbarros/godot-bullethell-game](https://github.com/joshbarros/godot-bullethell-game)

---

**Development Timeline:** Course started and completed December 26, 2025  
**Current Status:** Core gameplay complete, ready for expansion toward commercial release  
**Next Milestone:** Implement Phase 1 bullet hell mechanics from ROADMAP.md
