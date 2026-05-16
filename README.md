# gas_asm

FizzBuzz in **x86-64 GNU Assembler (Intel syntax)**, built with `gcc`,
interoperable with C, and demonstrated against both ABIs (System V on
Linux/macOS/BSD, Microsoft x64 on Windows / MinGW).

## 📖 Documentation

> **👉 Browse the docs online: <https://arkenidar.github.io/gas_asm/>**

A client-side Markdown browser (no server) renders everything in this
repo with syntax highlighting — including the `.s` and `.c` sources.

Two entry points:

- **[Reference](https://arkenidar.github.io/gas_asm/browse.html)** —
  building, ABI notes, SASM usage, System V across Unixes.
- **[Tutorial](https://arkenidar.github.io/gas_asm/tutorial/browse.html)** —
  seven chapters from "what is GAS" through `gdb` debugging.

## The code

| File | What it is |
|---|---|
| [`main.c`](main.c) | C driver that calls `fizzbuzz(20)` |
| [`fizzbuzz-abi-intel64-unix.s`](fizzbuzz-abi-intel64-unix.s) | System V AMD64 (Linux / macOS / BSD) |
| [`fizzbuzz-abi-intel64-unix-main.s`](fizzbuzz-abi-intel64-unix-main.s) | Same, with an inlined `main` (no `main.c` needed) |
| [`fizzbuzz-abi-intel64-mingw.s`](fizzbuzz-abi-intel64-mingw.s) | Microsoft x64 (Windows / MinGW) |
| [`fizzbuzz-abi-intel64-mingw-main.s`](fizzbuzz-abi-intel64-mingw-main.s) | Same, with an inlined `main` |

## Quick build

```sh
# Linux
gcc main.c fizzbuzz-abi-intel64-unix.s -o fizzbuzz && ./fizzbuzz

# Windows (MinGW / cross-compile)
x86_64-w64-mingw32-gcc main.c fizzbuzz-abi-intel64-mingw.s -o fizzbuzz.exe
```

See [the build chapter](https://arkenidar.github.io/gas_asm/tutorial/browse.html#06-build-and-run.md)
for the full pipeline, `as`-vs-`gcc` distinctions, and Wine.
