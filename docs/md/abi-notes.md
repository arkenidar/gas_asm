# ABI notes

The two `.s` files implement the same algorithm but follow different
x86-64 calling conventions. This page summarises what changes and why.

## Argument passing

| Slot | System V (Linux) | Microsoft x64 (Win64) |
|------|------------------|-----------------------|
| 1st int/ptr | `RDI` | `RCX` |
| 2nd int/ptr | `RSI` | `RDX` |
| 3rd int/ptr | `RDX` | `R8`  |
| 4th int/ptr | `RCX` | `R9`  |

So `fizzbuzz(int n)` reads `edi` in the Unix file and `ecx` in the MinGW
file. `printf("%d", i)` likewise uses `RDI`/`RSI` vs `RCX`/`RDX`.

## Varargs and `AL`

System V requires `AL` to hold the number of vector (XMM) registers used
when calling a variadic function such as `printf`. We pass no floats,
so the Unix file does `xor eax, eax` before every `call printf`. Win64
has no such requirement — the MinGW file omits it.

## Shadow space

Win64 mandates 32 bytes of **shadow space** above the return address
that the callee may freely scribble in. Before any `call` we need:

- 32 bytes shadow space, **and**
- 16-byte stack alignment.

After the 4 `push`es in `fizzbuzz`'s prologue, RSP%16 == 8, so we
`sub rsp, 40` (32 + 8) to satisfy both. The Unix file just needs
`sub rsp, 8` for alignment — no shadow space.

## Callee-saved registers

Both ABIs preserve `RBX`, `RBP`, `R12`–`R15`. Win64 *additionally*
preserves `RDI`, `RSI`, and `XMM6`–`XMM15`. The code here only uses
`RBX`, `R12`, `R13`, so the save/restore set is identical between
versions.

## RIP-relative addressing

Both files use `lea reg, [rip + label]` for string literals. This is
position-independent and works for both PIE Linux binaries and Win64
PE executables.

## Section directives

- Linux: `.section .rodata` for read-only string data.
- Win64: `.section .rdata,"dr"` — the `"dr"` flags mark it as data,
  read-only (PE has no `.rodata`).

## Quick diff cheatsheet

| Concern | Unix `.s` | MinGW `.s` |
|---------|-----------|------------|
| Read arg `n` | `mov r13d, edi` | `mov r13d, ecx` |
| `printf` 1st arg | `lea rdi, [rip+...]` | `lea rcx, [rip+...]` |
| `printf` 2nd arg | `mov esi, r12d` | `mov edx, r12d` |
| Pre-`call` AL zero | yes (`xor eax, eax`) | not required |
| Stack adjust before call | `sub rsp, 8` | `sub rsp, 40` |
| Rodata section | `.section .rodata` | `.section .rdata,"dr"` |
