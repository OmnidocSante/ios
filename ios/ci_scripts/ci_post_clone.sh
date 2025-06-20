#!/bin/sh

set -e  # Exit immediately on error

echo "==================== Cloning Flutter SDK ===================="
git clone https://github.com/flutter/flutter.git -b stable

export PATH="$PATH:$(pwd)/flutter/bin"

echo "==================== Flutter Version ===================="
flutter --version

echo "==================== Getting Dart & Flutter Dependencies ===================="
flutter pub get

echo "==================== Building iOS Artifacts ===================="
flutter build ios --release

echo "==================== Installing CocoaPods ===================="
cd ios
pod install
cd ..

echo "✅ Post-clone setup complete!"
