# Debugging GAS assembly with `gdb`

Assembly bugs tend to fall into a small number of buckets: a register
clobbered across a `call`, an argument placed in the wrong register, a
misaligned stack at the point of a `call`, or a bad memory reference.
`gdb` is well-suited to all of them — you just have to teach it to
speak Intel syntax and to show you registers instead of source lines.

## Build with debug info

Always pass `-g` so the assembler emits DWARF line info that maps back
to your `.s` file:

```sh
gcc -g main.c fizzbuzz-abi-intel64-unix.s -o fizzbuzz
```

`-g` works for `.s` inputs the same way it works for `.c` — `gcc`
forwards it to `as`, which records line numbers for each instruction.
Without it, `gdb` can still single-step, but it won't show the source
line next to the instruction.

For the self-contained variant:

```sh
gcc -g fizzbuzz-abi-intel64-unix-main.s -o fizzbuzz-main
```

## VS Code: allow breakpoints in assembly files

If VS Code refuses to place breakpoints in `.s` files, open
Settings -> Debug and set `debug.allowBreakpointsEverywhere` to `true`.

This repo also enables that setting in the workspace so assembly
breakpoints work out of the box.

## Tell `gdb` to use Intel syntax

The repo's `.s` files are Intel-syntax; by default `gdb` disassembles
in AT&T. Fix it once per session, or put it in `~/.gdbinit`:

```
set disassembly-flavor intel
```

## A first session

```sh
gdb ./fizzbuzz
```

Inside `gdb`:

```
(gdb) break fizzbuzz          # break on the assembly function
(gdb) run
(gdb) layout regs             # split view: source + registers
(gdb) si                      # step one instruction
(gdb) info registers          # dump all GPRs
(gdb) p/x $rdi                # print one register in hex
(gdb) x/16xb $rsp             # 16 bytes of stack, hex
(gdb) disas                   # disassemble current function
```

Key commands you'll reach for:

| Command                      | What it does                                          |
| ---------------------------- | ----------------------------------------------------- |
| `si` / `ni`                  | step **one instruction**; `ni` steps over `call`s     |
| `s` / `n`                    | step by **source line** (works with `-g`)             |
| `info registers`             | all general-purpose registers                         |
| `p/x $reg`                   | print one register in hex (`/d` decimal, `/t` binary) |
| `x/<n><fmt> addr`            | examine memory — e.g. `x/8gx $rsp` (8 giant hex)      |
| `disas` / `disas fizzbuzz`   | disassemble current frame / a function                |
| `bt`                         | backtrace                                             |
| `layout regs` / `layout asm` | TUI panes for registers / disassembly                 |

## Debugging the four common bugs

### 1. Wrong argument register

Set a breakpoint at function entry and inspect the ABI register
**before** anything else runs:

```
(gdb) break fizzbuzz
(gdb) run
(gdb) p/d $rdi        # System V: 1st int arg. Should print 20.
```

On Windows builds it's `$rcx`. If the value is garbage, the _caller_
put the argument in the wrong place — check the call site, not the
callee.

### 2. Clobbered callee-saved register

Set a breakpoint just **before** a `call` and another just **after**,
and compare:

```
(gdb) break *fizzbuzz+42       # before `call printf`
(gdb) break *fizzbuzz+47       # after it
(gdb) run
(gdb) p/x $rbx                 # at the first stop
(gdb) c
(gdb) p/x $rbx                 # at the second stop — must match
```

If `rbx`, `r12`–`r15`, `rbp`, or `rsp` change across a `call`, the
callee violated the ABI (or _you_ did, if you wrote it). Caller-saved
registers (`rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`–`r11`) are _expected_
to change — don't hold values in them across a `call`.

### 3. Misaligned stack at `call`

This is the classic "crashes inside `printf`" bug. At the instant of a
`call`, `rsp` must be `≡ 8 (mod 16)` — i.e. 16-byte aligned **after**
the `call` pushes the return address. Check it:

```
(gdb) break *fizzbuzz+42       # the instruction at the `call`
(gdb) run
(gdb) p $rsp & 0xf             # must be 8 just before `call`
```

If it's `0`, you're missing an 8-byte pad (or have one too many
`push`es); the segfault will appear _inside_ `printf` on the first SSE
instruction it executes.

### 4. Bad memory reference

When you see `SIGSEGV`, look at the faulting instruction and the
registers it dereferences:

```
(gdb) run
Program received signal SIGSEGV, Segmentation fault.
0x0000...  mov  eax, DWORD PTR [rdi+0x10]
(gdb) p/x $rdi
(gdb) x/4xw $rdi               # is this address even mapped?
```

`info proc mappings` shows which address ranges are valid.

## Useful one-liners

- Run to a specific instruction by address: `break *0x401234`.
- Watch a register change: `display/x $r12` (re-prints after every
  step).
- Skip past a noisy library call: `ni` instead of `si` on the `call`
  line.
- Inspect what `rip + label` resolves to: `p &fmt_num`, then
  `x/s &fmt_num` to read it as a C string.

## A note on optimisation and `-g`

Unlike with C, `-O2` does not rearrange your assembly — `as` emits
what you wrote. So `-g` alone gives a clean stepping experience; no
need for `-O0`. The only thing `-g` adds is the DWARF mapping back to
the `.s` file.

## Beyond `gdb`

- **`objdump -d -M intel fizzbuzz`** — static disassembly, handy for
  reading the final linked layout (PLT stubs, relocations).
- **`readelf -a`** — section headers, symbol table, dynamic entries.
- **`strace ./fizzbuzz`** — system-call trace; useful when the program
  hangs or exits silently before producing output.
- **`rr record ./fizzbuzz` + `rr replay`** — deterministic reverse
  debugging; pairs beautifully with single-stepping assembly.

---

Back to the [tutorial index](README.md).
