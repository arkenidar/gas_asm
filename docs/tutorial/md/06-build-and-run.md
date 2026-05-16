# Build & run

The mental model: **`gcc` is your assembler-and-linker front end.** It
recognises `.s` files, invokes GNU `as` on them, then links the result
against the C runtime so calls like `printf` resolve.

## Linux — C driver + library `.s`

```sh
gcc main.c fizzbuzz-abi-intel64-unix.s -o fizzbuzz
./fizzbuzz
```

Or step by step, to see the pipeline explicitly:

```sh
gcc -c fizzbuzz-abi-intel64-unix.s -o fizzbuzz.o   # assemble
gcc -c main.c                      -o main.o       # compile
gcc main.o fizzbuzz.o              -o fizzbuzz     # link
```

## Linux — self-contained (no `main.c`)

The `-main` variants inline their own `main`:

```sh
gcc fizzbuzz-abi-intel64-unix-main.s -o fizzbuzz-main
./fizzbuzz-main
```

Or — without using `gcc` as the assembler:

```sh
as  fizzbuzz-abi-intel64-unix-main.s -o fizzbuzz-main.o
gcc fizzbuzz-main.o                  -o fizzbuzz-main-as
```

### Common pitfall: `as file.s -o file` is **not** an executable

`as` only produces a relocatable ELF *object*. It has no `_start`
entry point, no C runtime, no dynamic linker reference. Marking it
executable with `chmod +x` won't help; the kernel will refuse to load
it (or it will segfault at the first instruction).

You always need a final `gcc` (or `ld` with the right `crt*` files and
`-lc`) pass to turn the object into a real executable.

## Windows (MinGW-w64)

From an MSYS2 / MinGW shell, native:

```sh
gcc main.c fizzbuzz-abi-intel64-mingw.s -o fizzbuzz.exe
./fizzbuzz.exe
```

Self-contained:

```sh
gcc fizzbuzz-abi-intel64-mingw-main.s -o fizzbuzz-main.exe
```

## Cross-compiling from Linux → Win64

```sh
sudo apt install gcc-mingw-w64-x86-64

x86_64-w64-mingw32-gcc main.c fizzbuzz-abi-intel64-mingw.s -o fizzbuzz.exe

wine fizzbuzz.exe        # run it without rebooting
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

## Where to go next

- For deeper command-line variations and the `as`-vs-`gcc`
  distinction, see [`docs/md/building.md`](../../md/building.md).
- For the calling-convention reference, see
  [`docs/md/abi-notes.md`](../../md/abi-notes.md).
- For loading the `-main` files inside the SASM IDE,
  [`docs/md/sasm.md`](../../md/sasm.md).

You now have everything you need to read, modify, and rebuild the
sample. The natural next exercise: change `fizzbuzz(20)` to a larger
number, or add a `Bazz` rule for multiples of 7 — you'll touch the
modulo block, a new string literal in `.rodata`, and the print-flag
logic, which is most of the file in miniature.

Next: [Debugging with `gdb` →](07-debugging.md)
