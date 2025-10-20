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
      # 正确转义 ~，否则不会替换
      newf="${f//\~/.}"
      ;;
    strip)
      base=$(basename "$f")
      prefix="${base%%~*}"       # 去掉 ~commit 及其后面
      arch="${base##*_}"         # 取架构段
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

# 如果没有匹配文件，也给个空输出，避免后续步骤出错
if [ ${#RENAMED_FILES[@]} -eq 0 ]; then
  {
    echo "files<<__EOF__"
    echo
    echo "__EOF__"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

# 使用 heredoc 一次性写入多行输出
{
  echo "files<<__EOF__"
  for f in "${RENAMED_FILES[@]}"; do
    echo "$f"
  done
  echo "__EOF__"
} >> "$GITHUB_OUTPUT"
