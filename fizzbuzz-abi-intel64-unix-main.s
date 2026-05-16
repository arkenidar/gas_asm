# fizzbuzz-abi-intel64-unix-main.s
#
# Self-contained variant: includes main() so it can be assembled & linked
# inside SASM (Linux) using the default GAS-based build.
#
# System V AMD64 ABI (Linux). Intel syntax.

        .intel_syntax noprefix

        .section .rodata
fmt_num:    .asciz "%d"
str_fizz:   .asciz "Fizz"
str_buzz:   .asciz "Buzz"
str_empty:  .asciz ""

        .text

# ---------------- main ----------------
        .globl  main
main:
        push    rbp
        mov     rbp, rsp                # stack now 16-byte aligned
        mov     edi, 20                 # fizzbuzz(20)
        call    fizzbuzz
        xor     eax, eax                # return 0
        pop     rbp
        ret

# -------------- fizzbuzz --------------
        .globl  fizzbuzz
fizzbuzz:
        push    rbp
        mov     rbp, rsp
        push    rbx                 # rbx = out flag
        push    r12                 # r12 = i
        push    r13                 # r13 = n (saved copy of arg)
        sub     rsp, 8              # keep 16-byte stack alignment before calls

        mov     r13d, edi           # n arrived in edi (1st int arg, SysV)
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
        lea     rdi, [rip + str_fizz]
        xor     eax, eax
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
        lea     rdi, [rip + str_buzz]
        xor     eax, eax
        call    printf
        mov     ebx, 1
.Lskip_buzz:

        # --- if (out == 0) printf("%d", i); ---
        test    ebx, ebx
        jnz     .Lskip_num
        lea     rdi, [rip + fmt_num]
        mov     esi, r12d
        xor     eax, eax
        call    printf
.Lskip_num:

        # --- puts("") -> newline ---
        lea     rdi, [rip + str_empty]
        call    puts

        inc     r12d
        jmp     .Lloop

.Ldone:
        add     rsp, 8
        pop     r13
        pop     r12
        pop     rbx
        pop     rbp
        ret
