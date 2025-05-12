#!/bin/bash

# Exit on error
set -e

# Check arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input.ll> <function_name>"
  exit 1
fi

INPUT_LL="$1"
TOP_FUNCTION="$2"
OUTPUT_LL="$1.out"

# Paths
CLANG=/opt/llvm-20-full/bin/clang++
LLVM_CONFIG=/opt/llvm-20-full/bin/llvm-config

# Build
echo "[*] Building inliner.cpp..."
$CLANG inliner.cpp -o inliner `$LLVM_CONFIG --cxxflags --ldflags --system-libs --libs core irreader ipo support` -std=c++17
echo "[+] Build complete."

# Run
echo "[*] Running inliner on $INPUT_LL (starting from $TOP_FUNCTION)..."
./inliner "$INPUT_LL" "$TOP_FUNCTION" > "$OUTPUT_LL"
echo "[+] Output written to $OUTPUT_LL"
