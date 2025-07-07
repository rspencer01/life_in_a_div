#!/bin/bash

set -euo pipefail

rm -rf target

echo -e "\033[1;32mStep 0 / 3\033[0m Checking build requirements..."
programs=("cargo" "wasm-strip" "wasm-opt")
for prog in "${programs[@]}"; do
  if ! command -v $prog &> /dev/null; then
    echo -e "\033[1;31mError\033[0m      Missing ${prog}"
    exit 1
  fi
done
  
echo -e "\033[1;32mStep 1 / 3\033[0m Building rust code..."
cargo build --target wasm32-unknown-unknown --release

echo -e "\033[1;32mStep 2 / 3\033[0m Stripping symbols..."
wasm-strip target/wasm32-unknown-unknown/release/life.wasm

echo -e "\033[1;32mStep 3 / 3\033[0m Optimising wasm..."
wasm-opt -o target/wasm32-unknown-unknown/life-opt.wasm -Oz target/wasm32-unknown-unknown/release/life.wasm

echo -e "Final program is $(stat -c%s target/wasm32-unknown-unknown/life-opt.wasm) bytes in size"
