# Anatomy of a `.s` file

Open [`fizzbuzz-abi-intel64-unix.s`](../../../fizzbuzz-abi-intel64-unix.s)
alongside this page. The file has four kinds of lines: **directives**,
**labels**, **instructions**, and **comments**.

## Comments

```gas
# This is a comment.
```

GAS treats `#` as a line comment. (Inside an instruction, `/* … */`
also works.)

## Directives — lines that start with `.`

Directives talk to the assembler, not the CPU. The important ones in
this project:

```gas
        .intel_syntax noprefix
```

Switches the file from AT&T syntax to Intel syntax. `noprefix` drops
the `%` that AT&T puts before register names. With it, you write
`mov rax, 1`, not `movq $1, %rax`.

```gas
        .text
        .section .rodata
```

`.text` is the section for executable code. `.rodata` is read-only
data — string literals live there:

```gas
fmt_num:    .asciz "%d"
str_fizz:   .asciz "Fizz"
```

`.asciz` emits the bytes of the string followed by a `\0`. That's
exactly what C's `printf` expects.

```gas
        .globl  fizzbuzz
fizzbuzz:
```

`.globl` exports a label so the linker can see it from other files —
this is how `main.c` finds `fizzbuzz`. Without `.globl` the symbol
would be file-local.

## Labels

A label is a name followed by `:`. It marks an address. Two flavours
appear in this project:

- **Global labels** (`fizzbuzz:`) — visible to the linker.
- **Local labels** (`.Lloop:`, `.Ldone:`) — by GAS convention, names
  starting with `.L` are stripped from the final object's symbol
  table. Use them for loop tops, branch targets, etc.

## Instructions

Intel syntax with `noprefix` reads left-to-right as **destination
first, then source(s)**:

```gas
        mov     r12d, 1          # r12d = 1
        cmp     r12d, r13d       # compare i, n
        jg      .Ldone           # jump if i > n
        lea     rdi, [rip + str_fizz]   # rdi = address of "Fizz"
        call    printf
```

Three details worth flagging:

- **Register widths**: `r12` is 64-bit, `r12d` is its low 32 bits,
  `r12w` the low 16, `r12b` the low 8. Writing the 32-bit form zero-
  extends into the 64-bit register on x86-64 — that's why `mov r12d, 1`
  is enough to give you `r12 = 1`.
- **Memory operands use brackets**: `[rip + str_fizz]` means "the
  address computed from `rip + offset_of(str_fizz)`". With `lea` you
  get the *address itself*; with `mov` you'd get what's *at* that
  address. The `rip +` form is the standard way to refer to data
  position-independently on x86-64.
- **`call` and the stack**: `call` pushes the return address (8 bytes)
  before jumping. That, plus the prologue's `push`es, is what the
  `sub rsp, 8` lines in this code are quietly balancing — see the
  [ABI chapter](05-abis.md) for the 16-byte alignment rule.

## Putting the pieces together

A minimal skeleton, in the same style as this project:

```gas
        .intel_syntax noprefix

        .section .rodata
hello:  .asciz "hello\n"

        .text
        .globl  greet
greet:
        push    rbp
        mov     rbp, rsp

        lea     rdi, [rip + hello]
        xor     eax, eax        # 0 vector regs for printf (SysV varargs)
        call    printf

        pop     rbp
        ret
```

That's a complete, linkable function `void greet(void);` you could call
from C.

Next: [Calling C from assembly →](04-c-interop.md)
