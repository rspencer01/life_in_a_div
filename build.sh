#!/bin/bash

set -euo pipefail

cargo build --target wasm32-unknown-unknown --release
wasm-strip target/wasm32-unknown-unknown/release/life.wasm
mkdir -p www
wasm-opt -o www/life.wasm -Oz target/wasm32-unknown-unknown/release/life.wasm
base64 www/life.wasm| wc -c
bash index.html.template > www/index.html
