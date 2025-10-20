#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-.}"
MODE="${MODE:-dot}"

shopt -s nullglob
RENAMED_FILES=()

for f in "$TARGET_DIR"/*~*.ipk; do
  [ -f "$f" ] || continue
  case "$MODE" in
    dot)
      newf="${f//~/.}"
      ;;
    strip)
      base=$(basename "$f")
      prefix="${base%%~*}"
      arch="${base##*_}"
      newf="$(dirname "$f")/${prefix}_${arch}"
      ;;
    *)
      echo "❌ Unknown MODE=$MODE"
      exit 1
      ;;
  esac
  if [ "$f" != "$newf" ]; then
    echo "Renaming $(basename "$f") -> $(basename "$newf")"
    mv "$f" "$newf"
  fi
  RENAMED_FILES+=("$newf")
done

{
  echo "files=$(printf '%s,' "${RENAMED_FILES[@]}" | sed 's/,$//')"
} >> "$GITHUB_OUTPUT"
