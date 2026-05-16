# fizzbuzz-abi-intel64-mingw-main.s
#
# Self-contained variant: includes main() so it can be assembled & linked
# inside SASM (Windows / MinGW-w64) using the default GAS-based build.
#
# Microsoft x64 ABI (Win64). Intel syntax.

        .intel_syntax noprefix

        .section .rdata,"dr"
fmt_num:    .asciz "%d"
str_fizz:   .asciz "Fizz"
str_buzz:   .asciz "Buzz"
str_empty:  .asciz ""

        .text

# ---------------- main ----------------
        .globl  main
main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32                 # 32 bytes shadow space; keeps 16-align
        mov     ecx, 20                 # fizzbuzz(20)  (Win64: 1st arg in ECX)
        call    fizzbuzz
        xor     eax, eax                # return 0
        add     rsp, 32
        pop     rbp
        ret

# -------------- fizzbuzz --------------
        .globl  fizzbuzz
fizzbuzz:
        push    rbp
        mov     rbp, rsp
        push    rbx                 # rbx = out flag
        push    r12                 # r12 = i
        push    r13                 # r13 = n
        sub     rsp, 40             # 32 shadow + 8 alignment

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
        lea     rcx, [rip + str_fizz]
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
        lea     rcx, [rip + fmt_num]
        mov     edx, r12d
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
