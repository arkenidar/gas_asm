# fizzbuzz-abi-intel64-mingw.s

# fizzbuzz.s — Microsoft x64 ABI (Win64), Intel syntax, GAS for MinGW-w64
#
# Exposes: void fizzbuzz(int n);

        .intel_syntax noprefix

        .section .rdata,"dr"
fmt_num:    .asciz "%d"
str_fizz:   .asciz "Fizz"
str_buzz:   .asciz "Buzz"
str_empty:  .asciz ""

        .text
        .globl  fizzbuzz
fizzbuzz:
        # Prologue: save callee-saved registers we'll use.
        # Win64 callee-saved: RBX, RBP, RDI, RSI, R12-R15, XMM6-XMM15.
        push    rbp
        mov     rbp, rsp
        push    rbx                 # rbx = out flag
        push    r12                 # r12 = i
        push    r13                 # r13 = n
        # 4 pushes = 32 bytes.  Entry RSP was 16-aligned-minus-8 (return addr),
        # so we now have RSP%16 == 8.  We need RSP%16 == 0 before any CALL,
        # plus 32 bytes of shadow space the callee may scribble in.
        # Total adjustment: 32 + 8 = 40 bytes.
        sub     rsp, 40

        mov     r13d, ecx           # n arrived in ECX (1st int arg, Win64)
        mov     r12d, 1             # i = 1

.Lloop:
        cmp     r12d, r13d
        jg      .Ldone

        xor     ebx, ebx            # out = 0

        # --- if (i % 3 == 0) printf("Fizz"); out = 1; ---
        mov     eax, r12d
        cdq
        mov     ecx, 3
        idiv    ecx
        test    edx, edx
        jnz     .Lskip_fizz
        lea     rcx, [rip + str_fizz]   # 1st arg in RCX (Win64)
        call    printf
        mov     ebx, 1
.Lskip_fizz:

        # --- if (i % 5 == 0) printf("Buzz"); out = 1; ---
        mov     eax, r12d
        cdq
        mov     ecx, 5
        idiv    ecx
        test    edx, edx
        jnz     .Lskip_buzz
        lea     rcx, [rip + str_buzz]
        call    printf
        mov     ebx, 1
.Lskip_buzz:

        # --- if (out == 0) printf("%d", i); ---
        test    ebx, ebx
        jnz     .Lskip_num
        lea     rcx, [rip + fmt_num]    # 1st arg: format
        mov     edx, r12d               # 2nd arg: i (Win64: RDX is 2nd)
        call    printf
.Lskip_num:

        # --- puts("") -> newline ---
        lea     rcx, [rip + str_empty]
        call    puts

        inc     r12d
        jmp     .Lloop

.Ldone:
        add     rsp, 40
        pop     r13
        pop     r12
        pop     rbx
        pop     rbp
        ret
