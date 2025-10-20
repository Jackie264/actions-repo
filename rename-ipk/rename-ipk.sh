#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-.}"
MODE="${MODE:-dot}"

shopt -s nullglob
for f in "$TARGET_DIR"/*~*.ipk; do
  [ -f "$f" ] || continue
  case "$MODE" in
    dot)
      newf="${f//~/.}"
      ;;
    strip)
      # 去掉 ~commit 部分，只保留前半段 + 架构
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
  echo "Renaming $(basename "$f") -> $(basename "$newf")"
  mv "$f" "$newf"
done
