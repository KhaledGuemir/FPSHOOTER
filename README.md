# FPSHOOTER 🌆🔫

A complete, standalone 3D First-Person Shooter developed with **Godot 4.7** and **Blender 5.3**.

---

## 🚀 Quick Launch
You can launch the game immediately using either:
- Double click **`Play_FPSHOOTER.bat`** (Windows Batch script)
- Or run **`Play_FPSHOOTER.ps1`** in PowerShell
- Or launch Godot directly pointing to this folder:
  ```powershell
  & "D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --path "D:\games\fpshooter"
  ```

---

## 🎮 Features & Checklist

- [x] **Sunset City Environment**:
  - Full procedural Physical Sky calibrated to golden-hour sunset lighting (`#ffa440`).
  - Directional sun casting long architectural shadows.
  - Volumetric dusk fog with ambient skylight scattering and glow post-processing.
  - Multi-tiered urban skyline: skyscrapers, mid-rise commercial buildings, street lamps, barriers.
- [x] **2 Custom Blender Weapons**:
  - **Pistol (Semi-Automatic)**: Sidearm with polymer grip, slide, barrel, and holographic sight. 12 round magazine.
  - **Assault Rifle (Fully-Automatic)**: Tactical carbine with extended barrel, shroud, curved magazine, stock, and optical scope. 30 round magazine.
- [x] **Procedural & Synthesized Audio**:
  - Handgun report (`pistol_shot.wav`)
  - Rifle automatic burst report (`rifle_shot.wav`)
  - Mechanical reloading cycle sound (`reload.wav`)
  - Kinetic surface impact and ping sound (`impact.wav`)
  - Explosive detonation boom (`explosion.wav`)
  - Weapon draw/switch sound (`switch.wav`)
- [x] **Combat & Particle VFX**:
  - Dynamic muzzle flash with light flares (`OmniLight3D`) and spark particles (`GPUParticles3D`).
  - Procedural weapon recoil impulse and smooth recovery animation.
  - Ricochet spark impact VFX on every raycast surface.
  - Target hit reactions, damage scaling, and particle detonation.
- [x] **Enemy Drone Target System & Scoring**:
  - Hovering and strafing target drones with patrol AI.
  - Health tracking per drone, hit reactions, and real-time score accumulation.
- [x] **HUD & In-Game Pause Menu**:
  - Floating crosshair, current weapon indicator, ammo counter, score counter, and health bar.
  - Interactive pause menu with **Resume**, **Restart Scene**, **Master Volume Slider**, and **Quit to Desktop**.

---

## 🕹️ Controls Guide
| Key / Input | Action |
|---|---|
| `W`, `A`, `S`, `D` | Movement |
| `Mouse` | Look around (Clamped vertical view) |
| `Left Shift` | Sprint |
| `Space` | Jump |
| `Left Mouse Button` | Fire Weapon |
| `1` | Switch to Pistol |
| `2` | Switch to Assault Rifle |
| `R` | Reload Weapon |
| `Esc` | Pause Menu / Release Mouse Cursor |

---

## 📦 Asset Architecture
- `assets/models/`:
  - `pistol.glb`, `rifle.glb`, `building_tower.glb`, `building_mid.glb`, `street_light.glb`, `barrier.glb`, `target_drone.glb`
- `assets/audio/`:
  - `pistol_shot.wav`, `rifle_shot.wav`, `reload.wav`, `impact.wav`, `explosion.wav`, `switch.wav`
- `scenes/`:
  - `main.tscn`: Main urban sunset arena with lighting, fog, buildings, and drone targets.
  - `player.tscn`: First-person controller with camera, dual weapons, audio players, HUD, and pause menu.
  - `target_drone.tscn`: Autonomous target drone scene.
  - `impact_effect.tscn`: Particle and light impact burst.
- `scripts/`:
  - `player.gd`, `target_drone.gd`, `impact_effect.gd`, `pause_menu.gd`, `main.gd`
- `generate_assets.py`: Full Blender Python script recreating all 3D geometry and materials.
- `generate_audio.py`: Standalone synthesis script for all game audio effects.
