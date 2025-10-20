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
      # 注意 ~ 要转义
      newf="${f//\~/.}"
      ;;
    strip)
      base=$(basename "$f")
      prefix="${base%%~*}"       # 去掉 ~commit 及后面
      arch="${base##*_}"         # all/ipk 架构部分
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

# 每行一个文件写到 GITHUB_OUTPUT
{
  for f in "${RENAMED_FILES[@]}"; do
    echo "files=$f"
  done
} >> "$GITHUB_OUTPUT"
