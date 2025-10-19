#!/usr/bin/env bash
set -euo pipefail

IPK_FILE="${IPK_FILE:?IPK_FILE not set}"
OUTPUT_DIR="${OUTPUT_DIR:-.}"

mkdir -p "$OUTPUT_DIR"

# 判断是否是现成的文件
if [ -f "$IPK_FILE" ]; then
  FILE="$IPK_FILE"
else
  # 尝试匹配相对路径和 ./ 前缀
  FILE=$(find . -type f \( -path "$IPK_FILE" -o -path "./$IPK_FILE" \) | head -n 1 || true)
fi

if [ -z "$FILE" ]; then
  echo "❌ No ipk file found matching: $IPK_FILE"
  exit 1
fi

BASENAME=$(basename "$FILE")
BASE="${BASENAME%.ipk}"

# pkg = everything before the last two underscore segments
PKG="${BASE%_*_*}"

# version = strip "<pkg>_" then drop the final underscore segment
VER_ARCH="${BASE#"${PKG}"_}"
VER_FULL="${VER_ARCH%_*}"
VER="${VER_FULL%%~*}"

# arch = last underscore segment
ARCH="${BASE##*_}"

echo "📦 Parsed: pkg=$PKG, ver=$VER, ver_full=$VER_FULL, arch=$ARCH"

# 输出到 GITHUB_OUTPUT
{
  echo "pkg=$PKG"
  echo "ver=$VER"
  echo "ver_full=$VER_FULL"
  echo "arch=$ARCH"
} >> "$GITHUB_OUTPUT"

# 也写到文件，方便调试或后续使用
{
  echo "pkg=$PKG"
  echo "ver=$VER"
  echo "ver_full=$VER_FULL"
  echo "arch=$ARCH"
} > "$OUTPUT_DIR/ipk-meta.txt"
