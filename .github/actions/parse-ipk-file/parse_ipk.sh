#!/usr/bin/env bash
set -euo pipefail

# parse_ipk_filename: extract pkg, version, arch from an .ipk filename
# Format: <pkg>_<version>_<arch>.ipk
parse_ipk_filename() {
  local fname="$1"
  local base="${fname%.ipk}"

  # pkg = everything before the last two underscore segments
  local pkg="${base%_*_*}"

  # version = strip "<pkg>_" then drop the final underscore segment
  local ver_arch="${base#"${pkg}"_}"
  local ver="${ver_arch%_*}"

  # arch = last underscore segment
  local arch="${base##*_}"

  echo "pkg=$pkg ver=$ver arch=$arch"
}
