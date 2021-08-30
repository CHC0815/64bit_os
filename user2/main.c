#include "../lib/lib.h"
#include "stdint.h"

int main(void)
{
    char *p = (char *)0xffff800000200200; // in kernel address space
    *p = 1;                               //should cause exception

    printf("Process2 %d\n");
    sleepu(1000);
    return 0;
}