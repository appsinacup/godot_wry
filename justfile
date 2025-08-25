#!/usr/bin/env just --justfile

os := if os() == "macos" { "macos" } else if os() == "windows" { "windows" } else { "linux" }
target := if os == "macos" { arch() + "-apple-darwin" } else if os == "windows" { arch() + "-pc-windows-msvc" } else { arch() + "-unknown-linux-gnu" }

default: build

set working-directory := 'rust'

build: 
	@echo "Building for {{os}} ({{target}})..."
	@just _build-{{os}}
	@just _copy-to-godot-{{os}}

build-static:
	@echo "Building static library for {{os}} ({{target}})..."
	@just _build-static-{{os}}
	@just _copy-static-to-godot-{{os}}

copy-to-godot: build
	@echo "Copying files to Godot project..."
	@just _copy-to-godot-{{os}}

clean:
	cargo clean

# Desktop platforms only (Linux x86_64, Windows, macOS)
build-all-platforms: build-linux-x64 build-windows-x64 build-windows-x32 build-windows-arm64 build-macos-x64 build-macos-arm64 build-macos-universal

# Static libraries for desktop platforms
build-all-static: build-static-linux-x64 build-static-windows-x64 build-static-windows-x32 build-static-windows-arm64 build-static-macos-x64 build-static-macos-arm64

_build-macos:
	cargo build --target {{target}} --locked --release
	mkdir -p ./target/{{target}}/release/libgodot_wry.framework/Resources
	mv ./target/{{target}}/release/libgodot_wry.dylib ./target/{{target}}/release/libgodot_wry.framework/libgodot_wry.dylib
	cp ../assets/Info.plist ./target/{{target}}/release/libgodot_wry.framework/Resources/Info.plist

_build-linux:
	cargo build --target {{target}} --locked --release

_build-windows:
	cargo build --target {{target}} --locked --release

_copy-to-godot-macos:
	mkdir -p ../godot/addons/godot_wry/bin/{{target}}
	cp -R ./target/{{target}}/release/libgodot_wry.framework ../godot/addons/godot_wry/bin/{{target}}

_copy-to-godot-linux:
	mkdir -p ../godot/addons/godot_wry/bin/{{target}}
	cp ./target/{{target}}/release/libgodot_wry.so ../godot/addons/godot_wry/bin/{{target}}/

_copy-to-godot-windows:
	mkdir -p ../godot/addons/godot_wry/bin/{{target}}
	cp ./target/{{target}}/release/godot_wry.dll ../godot/addons/godot_wry/bin/{{target}}/

build-all: build-macos-universal build-linux build-windows

build-macos-universal:
	@echo "Building universal macOS binary..."
	cargo build --target aarch64-apple-darwin --locked --release
	cargo build --target x86_64-apple-darwin --locked --release
	mkdir -p ./target/release/libgodot_wry.framework/Resources
	lipo -create -output ./target/release/libgodot_wry.dylib ./target/aarch64-apple-darwin/release/libgodot_wry.dylib ./target/x86_64-apple-darwin/release/libgodot_wry.dylib
	mv ./target/release/libgodot_wry.dylib ./target/release/libgodot_wry.framework/libgodot_wry.dylib
	cp ../assets/Info.plist ./target/release/libgodot_wry.framework/Resources/Info.plist
	mkdir -p ../godot/addons/godot_wry/bin/universal-apple-darwin
	cp -R ./target/release/libgodot_wry.framework ../godot/addons/godot_wry/bin/universal-apple-darwin

build-linux:
	@echo "Building for Linux..."
	just os="linux" build

build-windows:
	@echo "Building for Windows..."
	just os="windows" build

# Individual platform builds
build-linux-x64:
	@echo "Building for Linux x86_64..."
	cargo build --target x86_64-unknown-linux-gnu --locked --release
	mkdir -p ../godot/addons/godot_wry/bin/x86_64-unknown-linux-gnu
	cp ./target/x86_64-unknown-linux-gnu/release/libgodot_wry.so ../godot/addons/godot_wry/bin/x86_64-unknown-linux-gnu/

build-windows-x64:
	@echo "Building for Windows x86_64..."
	cargo build --target x86_64-pc-windows-msvc --locked --release
	mkdir -p ../godot/addons/godot_wry/bin/x86_64-pc-windows-msvc
	cp ./target/x86_64-pc-windows-msvc/release/godot_wry.dll ../godot/addons/godot_wry/bin/x86_64-pc-windows-msvc/

build-windows-x32:
	@echo "Building for Windows x86_32..."
	cargo build --target i686-pc-windows-msvc --locked --release
	mkdir -p ../godot/addons/godot_wry/bin/i686-pc-windows-msvc
	cp ./target/i686-pc-windows-msvc/release/godot_wry.dll ../godot/addons/godot_wry/bin/i686-pc-windows-msvc/

build-windows-arm64:
	@echo "Building for Windows ARM64..."
	cargo build --target aarch64-pc-windows-msvc --locked --release
	mkdir -p ../godot/addons/godot_wry/bin/aarch64-pc-windows-msvc
	cp ./target/aarch64-pc-windows-msvc/release/godot_wry.dll ../godot/addons/godot_wry/bin/aarch64-pc-windows-msvc/

build-macos-x64:
	@echo "Building for macOS x86_64..."
	cargo build --target x86_64-apple-darwin --locked --release
	mkdir -p ./target/x86_64-apple-darwin/release/libgodot_wry.framework/Resources
	mv ./target/x86_64-apple-darwin/release/libgodot_wry.dylib ./target/x86_64-apple-darwin/release/libgodot_wry.framework/libgodot_wry.dylib
	cp ../assets/Info.plist ./target/x86_64-apple-darwin/release/libgodot_wry.framework/Resources/Info.plist
	mkdir -p ../godot/addons/godot_wry/bin/x86_64-apple-darwin
	cp -R ./target/x86_64-apple-darwin/release/libgodot_wry.framework ../godot/addons/godot_wry/bin/x86_64-apple-darwin

build-macos-arm64:
	@echo "Building for macOS ARM64..."
	cargo build --target aarch64-apple-darwin --locked --release
	mkdir -p ./target/aarch64-apple-darwin/release/libgodot_wry.framework/Resources
	mv ./target/aarch64-apple-darwin/release/libgodot_wry.dylib ./target/aarch64-apple-darwin/release/libgodot_wry.framework/libgodot_wry.dylib
	cp ../assets/Info.plist ./target/aarch64-apple-darwin/release/libgodot_wry.framework/Resources/Info.plist
	mkdir -p ../godot/addons/godot_wry/bin/aarch64-apple-darwin
	cp -R ./target/aarch64-apple-darwin/release/libgodot_wry.framework ../godot/addons/godot_wry/bin/aarch64-apple-darwin

# Static library builds
build-static-linux-x64:
	@echo "Building static library for Linux x86_64..."
	cargo build --target x86_64-unknown-linux-gnu --locked --release
	mkdir -p ../godot/addons/godot_wry/bin/static/x86_64-unknown-linux-gnu
	cp ./target/x86_64-unknown-linux-gnu/release/libgodot_wry.a ../godot/addons/godot_wry/bin/static/x86_64-unknown-linux-gnu/

build-static-windows-x64:
	@echo "Building static library for Windows x86_64..."
	cargo build --target x86_64-pc-windows-msvc --locked --release
	mkdir -p ../godot/addons/godot_wry/bin/static/x86_64-pc-windows-msvc
	cp ./target/x86_64-pc-windows-msvc/release/godot_wry.lib ../godot/addons/godot_wry/bin/static/x86_64-pc-windows-msvc/

build-static-windows-x32:
	@echo "Building static library for Windows x86_32..."
	cargo build --target i686-pc-windows-msvc --locked --release
	mkdir -p ../godot/addons/godot_wry/bin/static/i686-pc-windows-msvc
	cp ./target/i686-pc-windows-msvc/release/godot_wry.lib ../godot/addons/godot_wry/bin/static/i686-pc-windows-msvc/

build-static-windows-arm64:
	@echo "Building static library for Windows ARM64..."
	cargo build --target aarch64-pc-windows-msvc --locked --release
	mkdir -p ../godot/addons/godot_wry/bin/static/aarch64-pc-windows-msvc
	cp ./target/aarch64-pc-windows-msvc/release/godot_wry.lib ../godot/addons/godot_wry/bin/static/aarch64-pc-windows-msvc/

build-static-macos-x64:
	@echo "Building static library for macOS x86_64..."
	cargo build --target x86_64-apple-darwin --locked --release
	mkdir -p ../godot/addons/godot_wry/bin/static/x86_64-apple-darwin
	cp ./target/x86_64-apple-darwin/release/libgodot_wry.a ../godot/addons/godot_wry/bin/static/x86_64-apple-darwin/

build-static-macos-arm64:
	@echo "Building static library for macOS ARM64..."
	cargo build --target aarch64-apple-darwin --locked --release
	mkdir -p ../godot/addons/godot_wry/bin/static/aarch64-apple-darwin
	cp ./target/aarch64-apple-darwin/release/libgodot_wry.a ../godot/addons/godot_wry/bin/static/aarch64-apple-darwin/
