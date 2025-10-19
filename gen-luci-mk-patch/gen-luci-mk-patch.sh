#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
PATCH_DIR="$ROOT_DIR/patches"
PATCH_FILE="$PATCH_DIR/0001-fix-luci-mk-include.patch"

# 可配置扫描目录，默认是 packages
PACKAGES_DIRS="${PACKAGES_DIRS:-packages}"

mkdir -p "$PATCH_DIR"
: > "$PATCH_FILE"

echo "🔍 Scanning for '../../luci.mk' includes in: $PACKAGES_DIRS"

FOUND=0

for dir in $PACKAGES_DIRS; do
  if [ ! -d "$dir" ]; then
    echo "⚠️  Directory $dir not found, skipping."
    continue
  fi

  while IFS= read -r mk; do
    if grep -qE '^[[:space:]]*include[[:space:]]+\.\./\.\./luci\.mk' "$mk"; then
      echo "⚡ Patching $mk"
      FOUND=$((FOUND+1))

      # 用 awk 替换，只改真正的 include 行
      awk '{
        if ($0 ~ /^[[:space:]]*include[[:space:]]+\.\.\/\.\.\/luci\.mk/) {
          sub(/\.\.\/\.\.\/luci\.mk/, "$(TOPDIR)/feeds/luci/luci.mk")
        }
        print
      }' "$mk" > "$mk.new"

      # 生成 diff 并追加到补丁文件
      diff -u "$mk" "$mk.new" >> "$PATCH_FILE" || true

      rm -f "$mk.new"
    fi
  done < <(find "$dir" -type f -name Makefile)
done

if [ -s "$PATCH_FILE" ]; then
  echo "📦 Patch generated at $PATCH_FILE (patched $FOUND files)"
else
  echo "✅ No Makefile needed patching."
  rm -f "$PATCH_FILE"
fi
