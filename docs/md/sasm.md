# Running inside SASM

[SASM](https://dman95.github.io/SASM/english.html) is a simple cross-platform
IDE for assembly that ships with GAS, NASM, MASM and FASM. The two
`*-main.s` variants are designed to be opened directly in SASM and run
without adding a separate C file.

## Why a `-main` variant?

SASM expects a single source file containing `main`. The library-style
`fizzbuzz-abi-intel64-unix.s` / `fizzbuzz-abi-intel64-mingw.s` files
only expose `fizzbuzz` and require [main.c](../../main.c) to be linked
alongside, which SASM's default build does not do.

The `-main` files inline a minimal `main` that calls `fizzbuzz(20)`, so
SASM's "Build & Run" works out of the box.

## Linux (Debian SASM package)

1. Open SASM.
2. Settings → Assembler: **GAS**, Mode: **x64**.
3. File → Open: `fizzbuzz-abi-intel64-unix-main.s`
4. Build & Run (F9).

## Windows (SASM with bundled MinGW-w64)

1. Open SASM.
2. Settings → Assembler: **GAS**, Mode: **x64**.
3. File → Open: `fizzbuzz-abi-intel64-mingw-main.s`
4. Build & Run (F9).

The two files differ only in calling convention — pick the one that
matches the host OS / ABI.

## Changing the upper bound

Both `-main` files hard-code `fizzbuzz(20)`. To try a different range,
edit the immediate in `main`:

- Linux: `mov edi, 20`
- Windows: `mov ecx, 20`
