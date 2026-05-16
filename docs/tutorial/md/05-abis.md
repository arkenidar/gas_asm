# Two ABIs side by side

x86-64 has two dominant calling conventions, and this repo ships one
`.s` file per ABI so each can be a clean example rather than a maze of
`#ifdef`-style hacks.

| ABI | Used by | This repo's file |
|-----|---------|------------------|
| **System V AMD64** | Linux, macOS, BSD | `fizzbuzz-abi-intel64-unix.s` |
| **Microsoft x64** | Windows (MSVC, MinGW-w64) | `fizzbuzz-abi-intel64-mingw.s` |

The algorithm is identical. Only the "where do args live, how is the
stack laid out" rules differ.

## Argument registers

| Position | System V | MS x64 |
|----------|----------|--------|
| 1st int/ptr | `RDI` | `RCX` |
| 2nd int/ptr | `RSI` | `RDX` |
| 3rd int/ptr | `RDX` | `R8` |
| 4th int/ptr | `RCX` | `R9` |
| 5th+ | stack | stack |

So `fizzbuzz(int n)` reads `edi` on Linux but `ecx` on Windows. The
two files differ in exactly that one prologue instruction, plus the
argument registers used when calling `printf`.

## Varargs and `AL`

System V says: before calling a variadic function (`printf`, `scanf`,
…), set `AL` to the number of XMM registers used to pass float args.
We pass none, so:

```gas
        xor     eax, eax        # AL = 0 vector args
        call    printf
```

MS x64 imposes no such rule. The MinGW file simply omits the `xor`.

## Stack: alignment + shadow space

Both ABIs want `RSP` aligned to **16 bytes** at the moment of a `call`.

Microsoft additionally requires **32 bytes of shadow space** above the
return address — scratch room the *callee* can use for spilling its
register arguments. The caller is responsible for reserving it, even
if the callee never touches it.

In this project's prologues:

| File | Pushes before first call | Adjust | Resulting `RSP%16` |
|------|--------------------------|--------|--------------------|
| Linux | 4 (`rbp`, `rbx`, `r12`, `r13`) | `sub rsp, 8` | 0 |
| MinGW | 4 (same set) | `sub rsp, 40` | 0, and 32 bytes shadow |

Get either of these wrong and `printf` typically crashes inside libc's
SSE-using code.

## Callee-saved registers

Both ABIs preserve `RBX`, `RBP`, `R12`–`R15`. MS x64 *also* preserves
`RDI`, `RSI`, and `XMM6`–`XMM15`.

This project keeps the loop counter in `R12` and a "did we already
print something this iteration?" flag in `RBX` — both callee-saved
under either ABI, so the save/restore set in the prologue/epilogue is
literally identical between the two files.

## Read-only data section

- Linux ELF: `.section .rodata`
- Windows PE: `.section .rdata,"dr"` — the `"dr"` flags mark it as
  data + read-only (PE has no `.rodata` name).

## One-glance diff

| Concern | Unix `.s` | MinGW `.s` |
|---------|-----------|------------|
| Read arg `n` | `mov r13d, edi` | `mov r13d, ecx` |
| `printf` 1st arg | `lea rdi, [rip+...]` | `lea rcx, [rip+...]` |
| `printf` 2nd arg | `mov esi, r12d` | `mov edx, r12d` |
| Pre-`call` `AL` zero | yes | not required |
| Stack adjust before call | `sub rsp, 8` | `sub rsp, 40` |
| rodata section | `.section .rodata` | `.section .rdata,"dr"` |

For the long-form version, see [`abi-notes.md`](../../md/abi-notes.md).

Next: [Build & run →](06-build-and-run.md)
