#!/bin/bash

set -euo pipefail

PATH=$PATH:./.buildtools/bin

rm -rf target

echo -e "\033[1;32mStep 0 / 4\033[0m   Checking build requirements..."
if ! command -v cargo &> /dev/null; then
  echo -e "\033[1;31mError\033[0m        Missing rust toolchain"
  exit 1
fi
if ! command -v wasm-strip &> /dev/null; then
  echo -e "\033[1;33mWarning\033[0m      Missing wasm-strip. Installing..."
  mkdir -p .buildtools/bin
  pushd .buildtools
  git clone --recursive https://github.com/WebAssembly/wabt
  cd wabt
  git submodule update --init
  mkdir build 
  cd build
  cmake ..
  cmake --build .
  popd
  ln -s $(pwd)/.buildtools/wabt/bin/wasm-strip .buildtools/bin/
fi
if ! command -v wasm-opt &> /dev/null; then
  echo -e "\033[1;33mWarning\033[0m      Missing wasm-opt. Installing..."
  mkdir -p .buildtools/bin || true
  pushd .buildtools
  git clone https://github.com/WebAssembly/binaryen.git
  cd binaryen
  git submodule update --init
  cmake . && make -j4
  popd
  ln -s $(pwd)/.buildtools/binaryen/bin/wasm-opt .buildtools/bin/
fi
  
echo -e "\033[1;32mStep 1 / 4\033[0m   Building rust code..."
rustup target add wasm32-unknown-unknown
cargo build --target wasm32-unknown-unknown --release

echo -e "\033[1;32mStep 2 / 4\033[0m   Stripping symbols..."
wasm-strip target/wasm32-unknown-unknown/release/life.wasm

echo -e "\033[1;32mStep 3 / 4\033[0m   Optimising wasm..."
wasm-opt -o target/wasm32-unknown-unknown/life-opt.wasm -Oz target/wasm32-unknown-unknown/release/life.wasm

echo -e "Final program is $(stat -c%s target/wasm32-unknown-unknown/life-opt.wasm) bytes in size"

echo -e "\033[1;32mStep 4 / 4\033[0m   Generating HTML..."
# This is [render](https://robertandrewspencer.com/static_html_generator/)
cat index.html.template | \
  sed '/^% /! s/"/\\\"/g' | \
  sed '/^% /! s/^\(.*\)/echo "\1"/' | \
  sed "s/^% \(.*\)/\1/" | \
  bash > index.html
