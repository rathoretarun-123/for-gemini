# Velocity Racer — phone-first Android racing prototype

Original 3D street-racing starter inspired by the genre, not using Need for Speed branding or proprietary assets.

## Controls
- Gas: accelerate
- Brake: slow down
- Left/right: steer
- N₂O: nitro boost
- Keyboard preview: W/Up, S/Down, A/D or arrows, Space

## Android target
OnePlus 11 / 11R, arm64-v8a, 8 GB RAM. Start with Godot Compatibility renderer and conservative mobile settings.

## APK build
The root workflow at .github/workflows/build-velocity-racer-android.yml attempts a cloud APK export on pushes to this project. A downloadable APK exists only after a successful workflow run. The project has not been verified on a physical phone.

## Current prototype limitations
Simple geometric car and road, arcade handling, basic city blocks. Not a finished AAA game. Opponent AI, race progression, car selection, tuning, audio, licensed assets, collision response, and advanced graphics remain future work.