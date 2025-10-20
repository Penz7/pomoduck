#!/bin/bash

echo "🔄 Generating translation files..."

# Generate codegen_loader.g.dart (translation data)
flutter packages pub run easy_localization:generate -S assets/translations -O lib/generated

# Generate locale_keys.g.dart (constants)
flutter packages pub run easy_localization:generate -S assets/translations -O lib/generated -o locale_keys.g.dart -f keys

echo "✅ Translation files generated successfully!"
echo "📁 Files created:"
echo "   - lib/generated/codegen_loader.g.dart"
echo "   - lib/generated/locale_keys.g.dart"
