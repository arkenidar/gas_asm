set disassembly-flavor intel
set pagination off

break main
break fizzbuzz
# break right after a modulo so we can inspect the remainder
break fizzbuzz-abi-intel64-mingw-main.s:55

run

echo \n===== Stopped at main =====\n
info registers rsp rbp rip
disassemble

echo \n===== Continue to fizzbuzz =====\n
continue
info args
echo \n--- n (r13d) and i (r12d) after prologue: step a few insns ---\n
# step 6 instructions to get past prologue (mov r13d,ecx ; mov r12d,1)
stepi 9
print/d $r12
print/d $r13

echo \n===== Continue to remainder check (line 55) =====\n
continue
echo i =
print/d $r12
echo i %% 3 remainder (edx) =
print/d $edx

echo \n===== Step into the next iterations a few times =====\n
continue
echo i =
print/d $r12
echo remainder =
print/d $edx

echo \n===== Let it run to completion =====\n
delete
continue

quit
