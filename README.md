# Nightlight for Android

The Mac game rebuilt in Godot (the Mac version's SpriteKit is Apple-only). Same rules, numbers, art and sound.
This repo is the Android project only; the Mac game's Swift code is not here.

## What you need

- **Godot 4.7.2 stable**, with its 4.7.2 export templates (the Android files `android_release.apk`, `android_debug.apk`, `android_source.zip`)
- **Java 17** (JDK), and the **Android SDK** with `platform-tools`, `build-tools;35.0.1` and `platforms;android-35`
- In Godot's Editor Settings, under Export > Android, point the Java and Android SDK paths at those installs

Renderer: GL Compatibility. Package: `com.kevinsingh.nightlight`. Android 7 or newer.

## Build the Android release

The release keystore and its password are deliberately not in this repo. Get them from Kevin, then:

```bash
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=/path/to/nightlight.keystore
export GODOT_ANDROID_KEYSTORE_RELEASE_USER=nightlight
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD='the password'
mkdir -p build
godot --headless --path . --import
godot --headless --path . --export-release Android build/Nightlight.apk
```

For PC emulators (x86_64): `godot --headless --path . --export-release "Android x86" build/Nightlight-x86_64.apk`

Raise `version/code` in `export_presets.cfg` for every new build (both presets). Every release must be signed with the same keystore, or it won't install over existing copies.

## Layout

- `scripts/`: the game. `game.gd` is one night, `data.gd` holds the rules, `main.gd` swaps screens and handles Back and app switching
- `shaders/`, `assets/`, `icon*.png`: art, sound, fonts, icons. Licences are in `assets/LICENSES.txt`
- `tools/dump/main.swift`: how art and sound were exported from the Mac game. It needs the Mac source, so it can't run from this repo; the results are already in `assets/`

## Testing

- Difficulty, no phone needed: `godot --headless --path . -- --balance 20 candle`
- Screen tests run on a debug build on a phone or emulator. Put `--selftest user://shots` or `--perf user://shots` in `user://test_args.txt`, because Android drops launch arguments
- Fake a camera hole on an emulator: `adb shell cmd overlay enable com.android.internal.display.cutout.emulation.hole`
- The build warning about `themed_icon` comes from Godot's own export template and is harmless
