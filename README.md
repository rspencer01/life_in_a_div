Life in a `<div>`
=================

A small rust program that compiles to a tiny WASM payload that plays Conway's [Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).

Much of this project is guided by [this excellent blog post](https://cliffle.com/blog/bare-metal-wasm/) which guides the reader through making tiny WASM graphics demos.

It was born when I needed a small payload to show an animated loading screen for a [reporting library I maintain](https://github.com/man-group/PyBloqs/blob/master/pybloqs/server/block/life_loading.py) and thought that a spinner was too boring.

### Where can I see it in action?
[Here.](https://rspencer01.github.io/life_in_a_div/)

### Where's the code?
[Here.](https://github.com/rspencer01/life_in_a_div/blob/main/src/lib.rs)

### How can I build it myself?
Run
```bash
./build.sh
```

### Why is it called "Life in a `<div>`"?
I wanted to call it "Life in a Box", but `<box>` isn't a valid HTML tag. In truth, the life is rendered in a `<canvas>` which invites puns about still life paintings but I'd already named the project and [Renaming Things is Hard](https://www.mostlypython.com/re-naming-things-is-hard/).
