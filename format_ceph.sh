#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./format_ceph.sh /path/to/ceph-repo [--check]

Description:
  Reformat Ceph source files with the repository-root .clang-format.
  Only files under the whitelist are considered.
  Paths matching the exclude list are skipped.

Options:
  --check   Do not edit files; only print files that would be formatted.
EOF
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

REPO_ROOT=$1
MODE="fix"

if [[ $# -eq 2 ]]; then
  if [[ $2 == "--check" ]]; then
    MODE="check"
  else
    usage
    exit 1
  fi
fi

if [[ ! -d $REPO_ROOT ]]; then
  echo "repo path not found: $REPO_ROOT" >&2
  exit 1
fi

if [[ ! -f $REPO_ROOT/.clang-format ]]; then
  echo ".clang-format not found in repo root: $REPO_ROOT" >&2
  exit 1
fi

if ! command -v clang-format >/dev/null 2>&1; then
  echo "clang-format not found in PATH" >&2
  exit 1
fi

WHITELIST_DIRS=(
  "src/common"
  "src/global"
  "src/include"
  "src/libcephfs"
  "src/librados"
  "src/librbd"
  "src/msg"
  "src/mon"
  "src/mgr"
  "src/mds"
  "src/os"
  "src/osd"
  "src/rgw"
  "src/tools"
  "src/test"
  "src/crimson"
)

EXCLUDE_PATTERNS=(
  "*/CMakeFiles/*"
  "*/build/*"
  "*/out/*"
  "*/.git/*"
  "*/__pycache__/*"
  "*/src/jaegertracing/*"
  "*/src/spdk/*"
  "*/src/rocksdb/*"
  "*/src/fio/*"
  "*/src/fmt/*"
  "*/src/xxHash/*"
  "*/src/rapidjson/*"
  "*/src/boost/*"
  "*/src/c-ares/*"
  "*/src/isa-l/*"
  "*/src/pmdk/*"
  "*/src/blk/*"
  "*/src/seastar/*"
  "*/src/dpdk/*"
  "*/src/userspace-rcu/*"
  "*/src/liburing/*"
  "*/src/arrow/*"
  "*/src/re2/*"
  "*/src/brotli/*"
  "*/src/zstd/*"
  "*/src/snappy/*"
  "*/src/googletest/*"
  "*/src/gtest/*"
  "*/src/include/ceph_ver.h*"
  "*/src/include/ceph_release.h*"
  "*/src/common/options/*.cc"
  "*/src/common/options/*.h"
  "*/src/*/*.pb.cc"
  "*/src/*/*.pb.h"
  "*/src/*/*_generated.*"
)

EXTENSIONS=(
  "*.c"
  "*.cc"
  "*.cpp"
  "*.cxx"
  "*.h"
  "*.hh"
  "*.hpp"
  "*.hxx"
  "*.ipp"
)

build_find_args() {
  local -n out=$1
  out=()

  local first_dir=1
  out+=( "(" )
  for dir in "${WHITELIST_DIRS[@]}"; do
    if [[ -d $REPO_ROOT/$dir ]]; then
      if [[ $first_dir -eq 0 ]]; then
        out+=( "-o" )
      fi
      out+=( "-path" "$REPO_ROOT/$dir" )
      first_dir=0
    fi
  done
  out+=( ")" )

  out+=( "-type" "f" "(" )
  local first_ext=1
  for ext in "${EXTENSIONS[@]}"; do
    if [[ $first_ext -eq 0 ]]; then
      out+=( "-o" )
    fi
    out+=( "-name" "$ext" )
    first_ext=0
  done
  out+=( ")" )

  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    out+=( "!" "-path" "$pattern" )
  done
}

main() {
  local find_args=()
  build_find_args find_args

  mapfile -d '' FILES < <(find "$REPO_ROOT" "${find_args[@]}" -print0 | sort -z)

  if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "no matching files found"
    exit 0
  fi

  echo "repo: $REPO_ROOT"
  echo "mode: $MODE"
  echo "file count: ${#FILES[@]}"

  if [[ $MODE == "check" ]]; then
    printf '%s\n' "${FILES[@]}"
    exit 0
  fi

  local file
  for file in "${FILES[@]}"; do
    clang-format -i -style=file "$file"
    printf 'formatted: %s\n' "$file"
  done
}

main
