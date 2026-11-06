#!/usr/bin/env bash
# Writes the Android and iOS launcher icons from build/icon/icon-1024.png
# (made by: flutter test tool/make_icon_test.dart). macOS only (uses sips).
set -euo pipefail
cd "$(dirname "$0")/.."

src=build/icon/icon-1024.png
[ -f "$src" ] || { echo "Run: flutter test tool/make_icon_test.dart" >&2; exit 1; }

# App stores refuse icons with an alpha channel: flatten through JPEG.
flat=build/icon/icon-1024-flat.png
sips -s format jpeg -s formatOptions 100 "$src" --out build/icon/flat.jpg >/dev/null
sips -s format png build/icon/flat.jpg --out "$flat" >/dev/null

resize() { sips -z "$1" "$1" "$flat" --out "$2" >/dev/null; }

# Android: legacy icon (48dp) and adaptive foreground (108dp, full bleed;
# Sunny sits inside the 66dp safe zone).
res=android/app/src/main/res
for pair in mdpi:1 hdpi:1.5 xhdpi:2 xxhdpi:3 xxxhdpi:4; do
  d=${pair%%:*}
  f=${pair##*:}
  resize "$(awk "BEGIN{print int(48*$f)}")" "$res/mipmap-$d/ic_launcher.png"
  resize "$(awk "BEGIN{print int(108*$f)}")" "$res/mipmap-$d/ic_launcher_foreground.png"
done

# iOS: every size listed in the asset catalog, named by pixel size.
ios=ios/Runner/Assets.xcassets/AppIcon.appiconset
for f in "$ios"/Icon-App-*.png; do
  name=$(basename "$f" .png)          # Icon-App-20x20@2x
  pt=${name#Icon-App-}; pt=${pt%%x*}  # 20 (or 83.5)
  scale=${name##*@}; scale=${scale%x} # 2
  resize "$(awk "BEGIN{print int($pt*$scale+0.5)}")" "$f"
done
echo "Icons written."
