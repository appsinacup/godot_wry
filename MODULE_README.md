# Godot Wry Module

A Godot engine module that integrates web view capabilities using the [WRY](https://github.com/tauri-apps/wry) library. This module automatically downloads and links against the static libraries from the GitHub releases.

## Features

- **Cross-platform web view support** for desktop platforms (Linux, Windows, macOS)
- **Automatic dependency management** - downloads static libraries from GitHub releases
- **Static linking** - no runtime dependencies to distribute
- **Native Godot integration** - built as a Godot module

## Installation

1. **Clone or copy this module** into your Godot source's `modules/` directory:
   ```bash
   cd godot/modules/
   git clone https://github.com/appsinacup/godot_wry.git
   ```

2. **Build Godot** with the module:
   ```bash
   cd godot
   scons platform=linux target=editor # or your target platform
   ```

3. **The module will automatically**:
   - Download the latest static libraries from GitHub releases
   - Extract the appropriate libraries for your platform
   - Link them during the build process

## Platform Support

| Platform | Architecture | Status |
|----------|-------------|---------|
| Linux    | x86_64      | ✅ Supported |
| Windows  | x86_64      | ✅ Supported |
| Windows  | x86_32      | ✅ Supported |
| Windows  | ARM64       | ✅ Supported |
| macOS    | x86_64      | ✅ Supported |
| macOS    | ARM64       | ✅ Supported |

## Usage

Once the module is built into Godot, you can use the `Webview` class in your GDScript:

```gdscript
extends Control

var webview: Webview

func _ready():
    webview = Webview.new()
    add_child(webview)
    webview.load_url("https://godotengine.org")
```

## Manual Library Installation

If the automatic download fails, you can manually place the static libraries:

1. Download the `godot_wry_static_libraries.zip` from [GitHub releases](https://github.com/appsinacup/godot_wry/releases)
2. Extract the appropriate library for your platform to `modules/godot_wry/libs/`:
   - Linux: `libgodot_wry.a`
   - Windows: `godot_wry.lib`
   - macOS: `libgodot_wry.a`
