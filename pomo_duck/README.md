# Before running the commands below, ensure you have the necessary dependencies in your `pubspec.yaml` file.
```flutter pub run build_runner build --delete-conflicting-outputs```

# Generate app icons
```flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-production.yaml```

# Generate languages
```flutter pub run intl_utils:generate```
```flutter pub run easy_localization:generate -S ./assets/translations -f keys -o locale_keys.g.dart -O ./lib/generated```

# Build apk 
Build release (mặc định app bundle APK single):
```bash build_apk.sh --release```
Build release per-ABI:
```bash build_apk.sh --release --split-per-abi```
Chọn flavor (ví dụ production, staging):
```bash build_apk.sh --release --flavor production```
Thiết lập version:
```bash build_apk.sh --release --build-name 1.2.3 --build-number 123```
Obfuscate và lưu symbol để debug crash:
```bash build_apk.sh --release --obfuscate --split-debug-info build/symbols```
Chỉ đích nền tảng:
```bash build_apk.sh --release --target-platform android-arm,android-arm64,android-x64```
Dart defines:
```bash build_apk.sh --release --dart-define API_BASE=https://api.example.com --dart-define ENV=prod```
Tắt tree-shake icons (nếu cần):
```bash build_apk.sh --release --no-tree-shake-icons```
Kết hợp ví dụ đầy đủ:
```bash build_apk.sh --release --flavor production --split-per-abi --obfuscate --split-debug-info build/symbols --build-name 1.3.0 --build-number 130 --dart-define ENV=prod```