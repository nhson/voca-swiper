#!/bin/bash
set -e

echo "=== Harness Initialization ==="

echo "=== flutter pub get ==="
flutter pub get

echo "=== dart format --output=none --set-exit-if-changed lib test content_pipeline ==="
dart format --output=none --set-exit-if-changed lib test content_pipeline

echo "=== flutter analyze ==="
flutter analyze

echo "=== flutter test ==="
flutter test

echo "=== Verification Complete ==="
echo ""
echo "Next steps:"
echo "1. Read feature_list.json to see current feature state"
echo "2. Pick ONE unfinished feature to work on"
echo "3. Implement only that feature"
echo "4. Re-run verification before claiming done"
