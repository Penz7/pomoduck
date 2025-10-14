# Before running the commands below, ensure you have the necessary dependencies in your `pubspec.yaml` file.
```flutter pub run build_runner build --delete-conflicting-outputs```

# Generate app icons
```flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-production.yaml```

# Generate languages
```flutter pub run intl_utils:generate```
```flutter pub run easy_localization:generate -S ./assets/translations -f keys -o locale_keys.g.dart -O ./lib/generated```

