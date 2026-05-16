# Building

All `.s` files use GAS Intel syntax (`.intel_syntax noprefix`). The
easiest path is to let `gcc` drive both assembling and linking.

## Linux (System V AMD64)

Using the C driver + the library-style `.s`:

```sh
gcc main.c fizzbuzz-abi-intel64-unix.s -o fizzbuzz
./fizzbuzz
```

Or step by step:

```sh
gcc -c fizzbuzz-abi-intel64-unix.s -o fizzbuzz.o
gcc -c main.c                      -o main.o
gcc main.o fizzbuzz.o              -o fizzbuzz
./fizzbuzz
```

Self-contained variant (no `main.c` needed):

```sh
gcc fizzbuzz-abi-intel64-unix-main.s -o fizzbuzz
./fizzbuzz
```

## Two assembler workflows for the `-main` files

The self-contained `-main` variants can be built two ways. Both
produce a working executable; pick whichever fits your toolchain
preferences.

### A) `gcc` as both assembler and linker (one step)

```sh
gcc fizzbuzz-abi-intel64-unix-main.s -o fizzbuzz-main
./fizzbuzz-main
```

`gcc` recognises the `.s` extension, invokes `as` internally, then
links against the C runtime so `printf` / `puts` resolve.

### B) `as` (GNU Assembler) + `gcc` as linker (two steps)

```sh
as  fizzbuzz-abi-intel64-unix-main.s -o fizzbuzz-main.o
gcc fizzbuzz-main.o                  -o fizzbuzz-main-as
./fizzbuzz-main-as
```

### Common pitfall

`as file.s -o file` does **not** produce a runnable binary — it
produces a relocatable ELF object. It is missing the C runtime startup
(`_start`, crt files) and the dynamic linker, so even with `chmod +x`
the kernel will refuse to execute it (or it will segfault immediately).

You must run the object through `gcc` (or `ld` with the right
crt/`libc` flags) to get an executable. The `-o fizzbuzz-main.o`
naming in step B above makes this distinction explicit.

> Note: there is no Debian package called `gas` or `as` — GNU `as`
> ships inside the **`binutils`** package, which is normally already
> installed alongside `gcc`.

## Windows (MinGW-w64)

Native, on Windows with MinGW-w64 installed:

```sh
gcc main.c fizzbuzz-abi-intel64-mingw.s -o fizzbuzz.exe
fizzbuzz.exe
```

Self-contained:

```sh
gcc fizzbuzz-abi-intel64-mingw-main.s -o fizzbuzz.exe
```

## Cross-compiling from Debian to Win64

```sh
sudo apt install gcc-mingw-w64-x86-64       # one-time

x86_64-w64-mingw32-gcc main.c fizzbuzz-abi-intel64-mingw.s -o fizzbuzz.exe

# Test under Wine without rebooting to Windows:
wine fizzbuzz.exe
```

Same approach for the self-contained `-main` variant:

```sh
x86_64-w64-mingw32-gcc fizzbuzz-abi-intel64-mingw-main.s -o fizzbuzz-main.exe
wine ./fizzbuzz-main.exe
```

## Expected output

```
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16
17
Fizz
19
Buzz
```
