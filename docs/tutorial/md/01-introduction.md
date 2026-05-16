# Introduction — Assembly the GAS / Intel-syntax way

This tutorial introduces the style of x86-64 assembly used in this
project: **GNU Assembler (GAS) with Intel syntax**, assembled and linked
through **`gcc`**, and callable from C.

## Why this style?

There are several ways to write x86-64 assembly. The three you'll meet
most often are:

| Tool | Syntax | Typical user |
|------|--------|--------------|
| **GAS** (`as`, via `gcc`) | AT&T by default, Intel optional | Linux / GCC toolchains |
| **NASM** / **YASM** | Intel | Standalone assembly projects, SASM |
| **MASM** | Intel | Windows / Visual Studio |

This project picks the combination that's most portable on a typical
Linux box (and on MinGW-w64 for Windows):

- **GAS** — already installed wherever `gcc` is installed (it ships in
  `binutils`). No extra package.
- **Intel syntax** — `mov dst, src`, square brackets for memory, no
  `%` register prefixes. Easier to read if you've seen Intel manuals,
  NASM tutorials, or SASM examples.
- **Driven by `gcc`** — one command assembles and links against the C
  runtime, so you can call `printf` and `puts` directly.

The result: short `.s` files that look like NASM, but build with the
tools you already have.

## What you'll learn

1. [Setup](02-setup.md) — what to install (almost nothing) and how to
   verify it.
2. [Anatomy of a `.s` file](03-anatomy.md) — directives, sections,
   labels, and what `.intel_syntax noprefix` actually changes.
3. [Calling C from assembly (and vice-versa)](04-c-interop.md) — how
   `fizzbuzz(int n)` is exposed to `main.c`, and how the ABI decides
   which register holds `n`.
4. [Two ABIs side by side](05-abis.md) — why there are separate `-unix`
   and `-mingw` files, and what actually differs between them.
5. [Build & run](06-build-and-run.md) — putting it together with
   `gcc` on Linux, MinGW on Windows, and cross-compiling with Wine.

## Prerequisites

You should be roughly comfortable with:

- Reading C function signatures (`void fizzbuzz(int n);`).
- Running commands in a shell.
- The idea of registers, the stack, and a function call — even if
  you've never written assembly before, this tutorial reintroduces the
  pieces as they appear.

You do **not** need prior GAS or NASM experience. If you've only seen
AT&T syntax (`movl %eax, %ebx`), the Intel form used here will feel
closer to pseudocode.

## The running example

Every chapter refers back to the same tiny program: **FizzBuzz from 1
to 20**, with the loop body written in assembly. It's small enough to
hold in your head, but large enough to exercise:

- function prologue / epilogue and callee-saved registers,
- signed division (`idiv`) for the modulo test,
- calls into the C library (`printf`, `puts`),
- variadic-call rules (why `xor eax, eax` appears before each
  `printf`),
- and the two competing 64-bit calling conventions.

Next: [Setup →](02-setup.md)
