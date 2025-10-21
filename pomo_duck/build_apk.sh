#!/usr/bin/env bash

set -euo pipefail

# --- Config ---
PROJECT_ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
  cat <<'USAGE'
Usage: bash build_apk.sh [options]

Options:
  --split-per-abi      Build per-ABI APKs (armeabi-v7a, arm64-v8a, x86_64)
  --skip-clean         Skip flutter clean
  --skip-gen-i18n      Skip easy_localization generation
  --flavor NAME        Build with product flavor (e.g. production, staging)
  --build-number N     Override build number (e.g. 42)
  --build-name S       Override build name (e.g. 1.2.3)
  --obfuscate          Enable Dart code obfuscation
  --split-debug-info D Store debug info symbols to directory D (with --obfuscate)
  --target-platform P  Target platform(s) (android-arm, android-arm64, android-x64)
  --dart-define K=V    Pass a Dart define (repeatable)
  --no-tree-shake-icons Do not tree-shake icons (default is tree-shake in release)
  --verbose            Pass --verbose to flutter build
  -h, --help           Show this help

This script builds RELEASE APK only.
Artifacts will be under build/app/outputs/flutter-apk/
USAGE
}

SPLIT_PER_ABI=false
SKIP_CLEAN=false
SKIP_GEN_I18N=false
FLAVOR=""
BUILD_NUMBER=""
BUILD_NAME=""
OBFUSCATE=false
SPLIT_DEBUG_INFO_DIR=""
TARGET_PLATFORM=""
NO_TREE_SHAKE_ICONS=false
VERBOSE=false
DART_DEFINES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --split-per-abi) SPLIT_PER_ABI=true ;;
    --skip-clean) SKIP_CLEAN=true ;;
    --skip-gen-i18n) SKIP_GEN_I18N=true ;;
    --flavor) FLAVOR="$2"; shift ;;
    --build-number) BUILD_NUMBER="$2"; shift ;;
    --build-name) BUILD_NAME="$2"; shift ;;
    --obfuscate) OBFUSCATE=true ;;
    --split-debug-info) SPLIT_DEBUG_INFO_DIR="$2"; shift ;;
    --target-platform) TARGET_PLATFORM="$2"; shift ;;
    --dart-define) DART_DEFINES+=("--dart-define=$2"); shift ;;
    --no-tree-shake-icons) NO_TREE_SHAKE_ICONS=true ;;
    --verbose) VERBOSE=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
  shift
done

cd "$PROJECT_ROOT_DIR"

echo "🏗  Android APK build started in: $PROJECT_ROOT_DIR"

if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ Flutter is not installed or not in PATH" >&2
  exit 1
fi

if [ "$SKIP_CLEAN" = false ]; then
  echo "🧹 flutter clean"
  flutter clean
fi

echo "📦 flutter pub get"
flutter pub get

if [ "$SKIP_GEN_I18N" = false ]; then
  if [ -f "$PROJECT_ROOT_DIR/generate_translations.sh" ]; then
    echo "🌐 Generating localizations"
    bash "$PROJECT_ROOT_DIR/generate_translations.sh"
  else
    echo "ℹ️  No generate_translations.sh found, skipping i18n generation"
  fi
fi

BUILD_FLAGS=()
if [ "$SPLIT_PER_ABI" = true ]; then
  BUILD_FLAGS+=("--split-per-abi")
fi
if [ -n "$FLAVOR" ]; then
  BUILD_FLAGS+=("--flavor" "$FLAVOR")
fi
if [ -n "$BUILD_NUMBER" ]; then
  BUILD_FLAGS+=("--build-number=$BUILD_NUMBER")
fi
if [ -n "$BUILD_NAME" ]; then
  BUILD_FLAGS+=("--build-name=$BUILD_NAME")
fi
if [ -n "$TARGET_PLATFORM" ]; then
  BUILD_FLAGS+=("--target-platform=$TARGET_PLATFORM")
fi
if [ "$OBFUSCATE" = true ]; then
  BUILD_FLAGS+=("--obfuscate")
  if [ -n "$SPLIT_DEBUG_INFO_DIR" ]; then
    mkdir -p "$SPLIT_DEBUG_INFO_DIR"
    BUILD_FLAGS+=("--split-debug-info=$SPLIT_DEBUG_INFO_DIR")
  fi
fi
if [ "$NO_TREE_SHAKE_ICONS" = true ]; then
  BUILD_FLAGS+=("--no-tree-shake-icons")
fi
if [ "$VERBOSE" = true ]; then
  BUILD_FLAGS+=("--verbose")
fi
if [ ${#DART_DEFINES[@]} -gt 0 ]; then
  BUILD_FLAGS+=("${DART_DEFINES[@]}")
fi

echo "🚀 Building Release APK..."
flutter build apk --release ${BUILD_FLAGS[*]:-}

echo "✅ Done. Artifacts located at: build/app/outputs/flutter-apk/"


