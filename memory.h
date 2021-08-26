#ifndef _MEMORY_H_
#define _MEMORY_H_

#include "stdint.h"

struct E820
{
    uint64_t address;
    uint64_t length;
    uint32_t type;
} __attribute__((packed));

struct FreeMemRegion
{
    uint64_t address;
    uint64_t length;
};

struct Page
{
    struct Page *next;
};

// page size of 2MB
#define PAGE_SIZE (2 * 1024 * 1024)
// page align up
#define PA_UP(v) ((((uint64_t)v + PAGE_SIZE - 1) >> 21) << 21)
// page align down
#define PA_DOWN(v) (((uint64_t)v >> 21) << 21)
// physical address to virtual address
#define P2V(p) ((uint64_t)(p) + 0xffff800000000000)
//virtual address to physical address
#define V2P(v) ((uint64_t)(v)-0xffff800000000000)

void init_memory(void);
void *kalloc(void);
void kfree(uint64_t v);

#endif