#!/usr/bin/env bash
# Uploads the release APK to the owner's Google Drive, folder "voca-swiper".
# Re-running replaces the file's content, so its Drive link stays the same.
#
# One-time sign-in (gives gcloud access to Drive):
#   gcloud auth login --enable-gdrive-access
# Then:
#   flutter build apk --release && tool/upload_apk.sh
set -euo pipefail

APK="${1:-build/app/outputs/flutter-apk/app-release.apk}"
FOLDER="voca-swiper"
NAME="voca-swiper.apk"
API="https://www.googleapis.com/drive/v3/files"
UPLOAD="https://www.googleapis.com/upload/drive/v3/files"

[[ -f "$APK" ]] || { echo "No APK at $APK — build it first." >&2; exit 1; }
TOKEN="$(gcloud auth print-access-token)"
AUTH=(-H "Authorization: Bearer $TOKEN")

json_get() { python3 -c "import sys,json; d=json.load(sys.stdin); print($1)"; }

# Folder: find or create.
q="name='$FOLDER' and mimeType='application/vnd.google-apps.folder' and trashed=false"
folder_id="$(curl -sfG "${AUTH[@]}" "$API" --data-urlencode "q=$q" \
  --data-urlencode "fields=files(id)" | json_get "d['files'][0]['id'] if d['files'] else ''")"
if [[ -z "$folder_id" ]]; then
  folder_id="$(curl -sf "${AUTH[@]}" -H "Content-Type: application/json" \
    -d "{\"name\":\"$FOLDER\",\"mimeType\":\"application/vnd.google-apps.folder\"}" \
    "$API?fields=id" | json_get "d['id']")"
  echo "Created Drive folder $FOLDER"
fi

# File: replace the existing one, or create it.
q="name='$NAME' and '$folder_id' in parents and trashed=false"
file_id="$(curl -sfG "${AUTH[@]}" "$API" --data-urlencode "q=$q" \
  --data-urlencode "fields=files(id)" | json_get "d['files'][0]['id'] if d['files'] else ''")"

size="$(stat -f%z "$APK" 2>/dev/null || stat -c%s "$APK")"
if [[ -n "$file_id" ]]; then
  method=PATCH; url="$UPLOAD/$file_id?uploadType=resumable"; meta='{}'
else
  method=POST; url="$UPLOAD?uploadType=resumable"
  meta="{\"name\":\"$NAME\",\"parents\":[\"$folder_id\"]}"
fi
session="$(curl -sfi -X "$method" "${AUTH[@]}" \
  -H "Content-Type: application/json; charset=UTF-8" \
  -H "X-Upload-Content-Type: application/vnd.android.package-archive" \
  -H "X-Upload-Content-Length: $size" \
  -d "$meta" "$url" | tr -d '\r' | awk -F': ' 'tolower($1)=="location"{print $2}')"
[[ -n "$session" ]] || { echo "Could not start the upload." >&2; exit 1; }

echo "Uploading $APK ($((size / 1024 / 1024)) MB)…"
file_id="$(curl -sf -X PUT -H "Content-Type: application/vnd.android.package-archive" \
  --upload-file "$APK" "$session" | json_get "d['id']")"
link="$(curl -sf "${AUTH[@]}" "$API/$file_id?fields=webViewLink,modifiedTime" \
  | json_get "d['webViewLink'] + '  (updated ' + d['modifiedTime'] + ')'")"
echo "Done: $link"
