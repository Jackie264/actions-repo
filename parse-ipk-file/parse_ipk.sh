#!/usr/bin/env bash
set -euo pipefail

IPK_FILE="${IPK_FILE:?IPK_FILE not set}"
OUTPUT_DIR="${OUTPUT_DIR:-.}"

mkdir -p "$OUTPUT_DIR"

# 支持 glob，取第一个匹配文件
FILE=$(ls -- "$IPK_FILE" 2>/dev/null | head -n 1 || true)

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
VER="${VER_ARCH%_*}"

# arch = last underscore segment
ARCH="${BASE##*_}"

echo "📦 Parsed: pkg=$PKG, ver=$VER, arch=$ARCH"

# 输出到 GITHUB_OUTPUT
{
  echo "pkg=$PKG"
  echo "ver=$VER"
  echo "arch=$ARCH"
} >> "$GITHUB_OUTPUT"

# 也写到文件，方便调试或后续使用
{
  echo "pkg=$PKG"
  echo "ver=$VER"
  echo "arch=$ARCH"
} > "$OUTPUT_DIR/ipk-meta.txt"
