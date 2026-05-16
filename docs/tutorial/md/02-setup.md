# Setup

You almost certainly have everything already.

## Linux (Debian / Ubuntu)

```sh
sudo apt install build-essential
```

That single package pulls in `gcc`, `make`, and **`binutils`** — and
`binutils` is where GNU `as` (the GAS assembler) lives. There is no
separate `gas` or `as` package on Debian.

Verify:

```sh
gcc --version
as  --version
```

Both should print a version banner.

## Windows

Install **MinGW-w64** (for example via [MSYS2](https://www.msys2.org/)).
After installation, from an MSYS2 / MinGW shell:

```sh
gcc --version
```

## Cross-compiling from Linux to Windows

Optional, but very convenient — you can build the `.exe` without
leaving Linux, then run it through **Wine**:

```sh
sudo apt install gcc-mingw-w64-x86-64 wine
```

You now have `x86_64-w64-mingw32-gcc`, which behaves like `gcc` but
emits Windows PE executables.

## Editor / SASM (optional)

The self-contained `-main` `.s` files in this repo are also designed to
load into **[SASM](https://dman95.github.io/SASM/english.html)**, a
small cross-platform IDE for assembly. SASM is not required for this
tutorial, but it's a pleasant way to step through code with a
breakpoint and watch registers update. See [`sasm.md`](../../md/sasm.md)
for details.

## Sanity check

From the project root:

```sh
gcc main.c fizzbuzz-abi-intel64-unix.s -o fizzbuzz
./fizzbuzz | head
```

If you see `1`, `2`, `Fizz`, `4`, `Buzz`, … you're ready.

Next: [Anatomy of a `.s` file →](03-anatomy.md)
