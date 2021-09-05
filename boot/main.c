#include "stdint.h"
#include "stddef.h"
#include "trap.h"
#include "print.h"
#include "debug.h"
#include "memory.h"
#include "process.h"
#include "syscall.h"

void KMain(void)
{
    printk("Kernel running");
    // init_idt();
    // init_memory();
    // init_kvm();
    // init_system_call();
    // init_process();
    // launch();
}