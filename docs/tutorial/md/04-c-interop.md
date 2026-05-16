# Calling C from assembly (and vice-versa)

The whole point of this style is that assembly and C are peers: each
side can call the other, as long as both agree on the **ABI** — the
calling convention.

## The C side

[`main.c`](../../../main.c) does just one thing:

```c
extern void fizzbuzz(int n);

int main(void) {
        fizzbuzz(20);
        return 0;
}
```

`extern` says: "this symbol exists somewhere else — the linker will
find it." That somewhere else is `fizzbuzz-abi-intel64-unix.s`, which
exported the name with `.globl fizzbuzz`.

## How `n` reaches the assembly

When `main` executes `fizzbuzz(20)`, it doesn't push `20` onto the
stack (this is x86-64, not x86). Instead, the ABI dictates a register:

- **System V AMD64** (Linux, macOS, BSD): first integer arg in `rdi` /
  `edi`.
- **Microsoft x64** (Windows, MinGW): first integer arg in `rcx` /
  `ecx`.

That's why the very first real instruction in the Linux file is:

```gas
        mov     r13d, edi        # n arrived in edi
```

…and in the Windows file it would be `mov ..., ecx`. Same logic, one
register's worth of difference. The [next chapter](05-abis.md) lays
the full table out.

## Calling C *from* assembly

`fizzbuzz` calls back into the C library three times per iteration:
`printf("Fizz")`, `printf("%d", i)`, `puts("")`. Each call has to obey
the same ABI rules, just in the other direction:

```gas
        lea     rdi, [rip + fmt_num]   # 1st arg: format string
        mov     esi, r12d              # 2nd arg: i
        xor     eax, eax               # 0 vector regs (varargs rule)
        call    printf
```

Three things are going on:

1. **Argument registers.** `rdi` then `rsi` then `rdx`, `rcx`, `r8`,
   `r9` for further integer/pointer args (System V). MS x64 uses
   `rcx, rdx, r8, r9`.
2. **Varargs vector count.** On System V, when calling a variadic
   function like `printf`, `al` must hold the number of XMM (SSE)
   registers used to pass floating-point args. We pass none, so
   `xor eax, eax` (which zeroes `al` as a side effect) is the standard
   idiom. Forget it and `printf` can crash on some libc builds.
3. **Callee-saved vs caller-saved.** The function chose to keep `i` in
   `r12` and a flag in `rbx` precisely because those are **callee-
   saved**: `printf` is guaranteed to preserve them. Had we used
   `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`–`r11`, the `printf` call
   could (and often does) clobber them.

## The prologue / epilogue, explained

```gas
        push    rbp
        mov     rbp, rsp
        push    rbx
        push    r12
        push    r13
        sub     rsp, 8           # alignment padding
        …
        add     rsp, 8
        pop     r13
        pop     r12
        pop     rbx
        pop     rbp
        ret
```

- `push rbp` / `mov rbp, rsp` sets up a frame pointer — optional on
  x86-64, but it makes the function easy to inspect in a debugger.
- The three `push`es save the callee-saved registers we plan to clobber
  (`rbx`, `r12`, `r13`). The epilogue pops them back in reverse order.
- `sub rsp, 8` aligns the stack to 16 bytes **before** any `call`.
  Counting bytes: `call` pushed 8, our four `push`es pushed 32, total
  40 — not a multiple of 16. Add 8 more and `rsp` is 16-byte aligned,
  which is what the ABI requires at the point of a call.

Get the alignment wrong and you'll see weird crashes inside `printf`,
because `printf` uses SSE instructions that require aligned stack.

Next: [Two ABIs side by side →](05-abis.md)
