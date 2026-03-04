#!/usr/bin/env bash
# Download + extract the 14 GB Yandex facades test set (697 unlabeled PNGs).
# Resumable: re-running continues a partial download and skips if already extracted.
set -euo pipefail
cd "$(dirname "$0")/test"          # download/extract into Task2/test/ (gitignored)

PUB="https://disk.yandex.com/d/VFEIGpGh-MkvwA"
ZIP="facades_dataset_v0.zip"
OUT="facades_dataset_v0"

if [ -d "$OUT" ] && [ "$(ls -1 "$OUT"/*.png 2>/dev/null | wc -l)" -ge 697 ]; then
  echo "Already extracted ($(ls -1 "$OUT"/*.png | wc -l) PNGs) — nothing to do."
  exit 0
fi

echo "Resolving Yandex download URL..."
HREF=$(curl -s --max-time 30 \
  "https://cloud-api.yandex.net/v1/disk/public/resources/download?public_key=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1],safe=''))" "$PUB")" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['href'])")

echo "Downloading $ZIP (~14 GB, resumable)..."
curl -L -C - --retry 5 --retry-delay 10 -o "$ZIP" "$HREF"

echo "Extracting..."
unzip -q -o "$ZIP" -d .
echo "Done: $(ls -1 "$OUT"/*.png 2>/dev/null | wc -l) PNGs extracted."
