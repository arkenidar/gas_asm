
// https://claude.ai/chat/d7655964-17ae-4761-888d-32c87db79cc1
// FizzBuzz implementation in C++

#include <stdio.h>

extern void fizzbuzz(int n);

int main(void) {
    fizzbuzz(20);
    return 0;
}

// gcc main.c fizzbuzz.s -o fizzbuzz

/*

oneliner for:

gcc -c fizzbuzz.s -o fizzbuzz.o
gcc -c main.c     -o main.o
gcc main.o fizzbuzz.o -o fizzbuzz
./fizzbuzz

*/


/*

in Debian to Cross-Compile to Win64

sudo apt install gcc-mingw-w64-x86-64        # one-time install

x86_64-w64-mingw32-gcc main.c fizzbuzz.s -o fizzbuzz.exe

# Test under Wine if you don't want to reboot to Windows:
wine fizzbuzz.exe

*/
