# Tutorial — GAS / Intel-syntax assembly, driven by `gcc`

An introductory walkthrough of the style used in this repo: x86-64
assembly written in **GNU Assembler Intel syntax**, built with `gcc`,
and interoperable with C.

1. [Introduction](01-introduction.md) — why this combination of tools.
2. [Setup](02-setup.md) — what to install (almost nothing).
3. [Anatomy of a `.s` file](03-anatomy.md) — directives, sections,
   labels, instructions.
4. [Calling C from assembly](04-c-interop.md) — ABI in practice.
5. [Two ABIs side by side](05-abis.md) — System V vs Microsoft x64.
6. [Build & run](06-build-and-run.md) — Linux, Windows, and Wine.
7. [Debugging with `gdb`](07-debugging.md) — `-g`, Intel-syntax
   disassembly, and the four bugs you'll actually hit.

The running example is the FizzBuzz code at the repository root. For
short-form reference material (commands, ABI tables, SASM usage), see
[`../../md/`](../../md/).
