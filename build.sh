#!/bin/bash

set -euo pipefail

cargo build --target wasm32-unknown-unknown --release
wasm-strip target/wasm32-unknown-unknown/release/life.wasm
wasm-opt -o target/wasm32-unknown-unknown/life-opt.wasm -Oz target/wasm32-unknown-unknown/release/life.wasm
ls -l target/wasm32-unknown-unknown/life-opt.wasm
bash index.html.template > index.html
