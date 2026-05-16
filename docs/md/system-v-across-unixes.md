# System V across Unixes (Linux, BSD, macOS)

**System V** originally refers to AT&T's UNIX System V (1983), but in modern
low-level / assembly programming usage it almost always means the
**System V ABI** — the Application Binary Interface that defines how compiled
code interacts with the OS and with other code at the binary level.

This page complements [ABI notes](abi-notes.md) (which contrasts System V with
the Microsoft x64 ABI) by looking at how System V itself varies across the
Unix-like systems that all claim to follow it.

## "Unix" vs "Unix-like" — a terminology note

Throughout this document "Unix" is used in the everyday, loose sense. There are
really two definitions:

1. **UNIX® (trademark-strict)** — only systems certified against the Single
   UNIX Specification by The Open Group. By this definition: **macOS**,
   **Solaris**, **AIX**, **HP-UX**, and **z/OS UNIX** qualify.
   **GNU/Linux**, the **BSDs**, and **illumos** do *not* — they were never
   certified (or the certification lapsed).
2. **Unix-like (everyday usage)** — systems that follow POSIX and the classic
   Unix design (processes, fds, `fork`/`exec`, a `/`-rooted filesystem) and
   descend from or reimplement the AT&T Unix lineage. By this definition
   Linux, the BSDs, macOS, Solaris, illumos, AIX, HP-UX all count.

Ironically, by the strict trademark definition, **macOS is the only "real
Unix"** among the popular desktop/server systems most developers use today,
while Linux is not.

For the **System V ABI** the distinction does not matter: the ABI is a binary
contract independent of trademarks, and what counts is whether the OS
implements it. So in this document "Unixes" means "Unix-like systems that
adopted the System V ABI" — the useful grouping for an assembly programmer.

## What the System V ABI specifies

- **Calling conventions** — how function arguments are passed (registers vs.
  stack), how return values come back, which registers are caller- vs.
  callee-saved.
- **Object file format** — ELF (Executable and Linkable Format).
- **System call conventions** — how userspace invokes the kernel.
- **Stack layout, alignment, symbol naming.**

### x86-64 System V calling convention

- Integer / pointer args: `RDI, RSI, RDX, RCX, R8, R9`, then stack.
- Floating point args: `XMM0`–`XMM7`.
- Return value: `RAX` (and `RDX` for 128-bit returns).
- Callee-saved: `RBX, RBP, R12`–`R15`.
- 16-byte stack alignment required before every `call`.
- Linux syscalls: number in `RAX`, args in `RDI, RSI, RDX, R10, R8, R9`,
  instruction `syscall`.

## Across the Unixes

| System | ABI | Binary format | Notes |
|--------|-----|---------------|-------|
| **GNU/Linux** | System V AMD64 ABI | ELF | The reference implementation in practice. Syscall numbers are Linux-specific. |
| **FreeBSD / OpenBSD / NetBSD** | System V AMD64 ABI | ELF | Same calling convention as Linux, but **different syscall numbers** and some syscall mechanism details. |
| **macOS (Darwin)** | System V AMD64 ABI (with tweaks) | **Mach-O**, not ELF | Same register-passing rules. Syscall numbers are offset (e.g. `0x2000000 + n` for BSD-class syscalls), C symbols are prefixed with `_`, and code typically goes through `libSystem` rather than raw `syscall`. Apple Silicon uses the ARM64 AAPCS variant, not System V. |
| **Solaris / illumos** | The original System V ABI | ELF | The literal descendant of AT&T System V. |

## Takeaways for portable assembly

1. **Calling convention** (how to call C functions) is essentially identical
   across Linux, the BSDs, and macOS on x86-64 — write once.
2. **Syscalls are not portable** — numbers and even mechanisms differ. Prefer
   calling libc (`write`, `read`, `printf`, …) rather than raw `syscall` if you
   want cross-Unix code.
3. **Object format differs** — ELF everywhere except macOS (Mach-O).
   Assemblers like `gas` / `nasm` need different output flags.
4. **Symbol naming** — macOS prefixes C symbols with `_` (`_printf`); Linux and
   the BSDs do not.
5. **Windows x86-64 is different** — it uses the Microsoft x64 ABI
   (`RCX, RDX, R8, R9`), not System V. See [ABI notes](abi-notes.md).

So "System V" in practice today means: *the shared x86-64 calling convention
that all the Unix-likes agreed on*, layered on top of OS-specific syscall
tables and object formats.

## Portability of the `-unix.s` file in this repo

A natural question: is [fizzbuzz-abi-intel64-unix.s](../../fizzbuzz-abi-intel64-unix.s)
Debian-only, Linux-only, or genuinely Unix-wide? The `unix` in the filename is
correctly broad — nothing in the file is Debian- or even Linux-specific.

### Works as-is

- **Any GNU/Linux distro** — Debian, Ubuntu, Fedora, Arch, Alpine, …
- **FreeBSD / OpenBSD / NetBSD** on x86-64 — same calling convention, same ELF
  format, `printf` from libc.
- **Solaris / illumos** on x86-64 — same ABI, same ELF.

The file only calls `printf` (a libc function), never a raw syscall, so the
"syscall numbers differ between Linux and the BSDs" caveat above does **not**
apply here.

### Needs changes

- **macOS** — same calling convention, but:
  - Output format is **Mach-O**, not ELF.
  - C symbols are prefixed with `_`, so `call printf` becomes `call _printf`.
  - `.section .rodata` is not the macOS section name (use
    `.section __TEXT,__cstring` or equivalent).
- **Windows** — that's what
  [fizzbuzz-abi-intel64-mingw.s](../../fizzbuzz-abi-intel64-mingw.s) is for.

A more precise label for the file would be "x86-64 ELF Unixes"; Debian is just
the most common test environment.
