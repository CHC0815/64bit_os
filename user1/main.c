#include "../lib/lib.h"
#include "stdint.h"

int main(void)
{
    int64_t counter = 0;

    while (1)
    {
        if (counter % 10000000 == 0)
            printf("Process1 %d\n", counter);
        counter++;
    }
    return 0;
}