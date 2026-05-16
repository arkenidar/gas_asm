# gas_asm — FizzBuzz in GAS (Intel syntax)

Small demo showing the same FizzBuzz routine written in GNU Assembler
(Intel syntax) for two x86-64 ABIs, plus a C driver and self-contained
variants ready to load into [SASM](https://dman95.github.io/SASM/english.html).

## Files

| File | Purpose |
|------|---------|
| [main.c](../../main.c) | C driver: calls `fizzbuzz(20)` |
| [fizzbuzz-abi-intel64-unix.s](../../fizzbuzz-abi-intel64-unix.s) | `fizzbuzz` only — System V AMD64 (Linux) |
| [fizzbuzz-abi-intel64-mingw.s](../../fizzbuzz-abi-intel64-mingw.s) | `fizzbuzz` only — Microsoft x64 (Win64 / MinGW-w64) |
| [fizzbuzz-abi-intel64-unix-main.s](../../fizzbuzz-abi-intel64-unix-main.s) | Self-contained Linux variant with inlined `main` |
| [fizzbuzz-abi-intel64-mingw-main.s](../../fizzbuzz-abi-intel64-mingw-main.s) | Self-contained Windows variant with inlined `main` |

## Documentation index

- [Building](building.md) — gcc command lines, cross-compiling to Win64
- [SASM usage](sasm.md) — opening the `-main` variants inside SASM
- [ABI notes](abi-notes.md) — calling-convention differences between the two `.s` files
- [System V across Unixes](system-v-across-unixes.md) — how the System V ABI varies between Linux, the BSDs, and macOS
