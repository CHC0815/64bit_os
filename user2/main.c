#include "../lib/lib.h"
#include "stdint.h"

int main(void)
{
    while (1)
    {
        printf("Process2 %d\n");
        sleepu(1000);
    }
    return 0;
}