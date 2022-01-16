#include "process.h"
#include "trap.h"
#include "memory.h"
#include "print.h"
#include "lib.h"
#include "debug.h"
#include "stddef.h"

extern struct TSS Tss;
static struct Process process_table[NUM_PROC];
static int pid_num = 1;
static struct ProcessControl pc;

extern void swap(uint64_t *a, uint64_t b);

static void set_tss(struct Process *proc)
{
    Tss.rsp0 = proc->stack + STACK_SIZE;
}

static struct Process *find_unused_process(void)
{
    struct Process *process = NULL;

    for (int i = 0; i < NUM_PROC; i++)
    {
        if (process_table[i].state == PROC_UNUSED)
        {
            process = &process_table[i];
            break;
        }
    }

    return process;
}

static void set_process_entry(struct Process *proc, uint64_t addr)
{
    uint64_t stack_top;

    proc->state = PROC_INIT;
    proc->pid = pid_num++;

    proc->stack = (uint64_t)kalloc(); //kernel stack
    ASSERT(proc->stack != 0);

    memset((void *)proc->stack, 0, PAGE_SIZE);
    stack_top = proc->stack + STACK_SIZE;

    proc->context = stack_top - sizeof(struct TrapFrame) - 7 * 8;
    *(uint64_t *)(proc->context + 6 * 8) = (uint64_t)TrapReturn; // 6*8 = 48 = 6 registers --> swap are 6 registers -> TrapReturn is return address

    proc->tf = (struct TrapFrame *)(stack_top - sizeof(struct TrapFrame));
    proc->tf->cs = 0x10 | 3;
    proc->tf->rip = 0x400000;
    proc->tf->ss = 0x18 | 3;
    proc->tf->rsp = 0x400000 + PAGE_SIZE;
    proc->tf->rflags = 0x202;

    proc->page_map = setup_kvm();
    ASSERT(proc->page_map != 0);
    ASSERT(setup_uvm(proc->page_map, P2V(addr), 5120)); // 10 sectors a 512 bytes = 5120
    proc->state = PROC_READY;
}

static struct ProcessControl *get_pc(void)
{
    return &pc;
}

static void init_idle_process(void)
{
    struct Process *process;
    struct ProcessControl *process_control;

    process = find_unused_process();
    ASSERT(process == &process_table[0]);

    process->pid = 0;
    process->page_map = P2V(read_cr3());
    process->state = PROC_RUNNING;

    process_control->current_process = process;
}

static void init_user_process(void)
{
    struct Process *process;
    struct ProcessControl *process_control;
    struct HeadList *list;

    process_control = get_pc();
    list = &process_control->ready_list;

    process = alloc_new_process();
    ASSERT(process != NULL);

    ASSERT(setup_uvm(process->page_map, P2V(0x30000), 5120));

    process->state = PROC_READY;
    append_list_tail(list, (struct List *)process);
}

void init_process(void)
{
    init_idle_process();
    init_user_process();
}

void launch(void)
{
    struct ProcessControl *process_control;
    struct Process *process;

    process_control = get_pc();
    process = (struct Process *)remove_list_head(&process_control->ready_list);
    process->state = PROC_RUNNING;
    process_control->current_process = process;

    set_tss(process);
    switch_vm(process->page_map);
    pstart(process->tf);
}

static void switch_process(struct Process *prev, struct Process *current)
{
    set_tss(current);
    switch_vm(current->page_map);
    swap(&prev->context, current->context);
}

static void schedule(void)
{
    struct Process *prev_proc;
    struct Process *current_proc;
    struct ProcessControl *process_control;
    struct HeadList *list;

    process_control = get_pc();
    prev_proc = process_control->current_process;
    list = &process_control->ready_list;
    ASSERT(!is_list_empty(list));

    current_proc = (struct Process *)remove_list_head(list);
    current_proc->state = PROC_RUNNING;
    process_control->current_process = current_proc;

    switch_process(prev_proc, current_proc);
}

void yield(void)
{
    struct ProcessControl *process_control;
    struct Process *process;
    struct HeadList *list;

    process_control = get_pc();
    list = &process_control->ready_list;

    if (is_list_empty(list))
    {
        return;
    }

    process = process_control->current_process;
    process->state = PROC_READY;
    append_list_tail(list, (struct List *)process);
    schedule();
}

void sleep(int wait)
{
    struct ProcessControl *process_control;
    struct Process *process;

    process_control = get_pc();
    process = process_control->current_process;
    process->state = PROC_SLEEP;
    process->wait = wait;

    append_list_tail(&process_control->wait_list, (struct List *)process);
    schedule();
}

void wake_up(int wait)
{
    struct ProcessControl *process_control;
    struct Process *process;
    struct HeadList *ready_list;
    struct HeadList *wait_list;

    process_control = get_pc();
    ready_list = &process_control->ready_list;
    wait_list = &process_control->wait_list;
    process = (struct Process *)remove_list(wait_list, wait);

    while (process != NULL)
    {
        process->state = PROC_READY;
        append_list_tail(ready_list, (struct List *)process);
        process = (struct Process *)remove_list(wait_list, wait);
    }
}

void exit(void)
{
    struct ProcessControl *process_control;
    struct Process *process;
    struct HeadList *list;

    process_control = get_pc();
    process = process_control->current_process;
    process->state = PROC_KILLED;

    list = &process_control->kill_list;
    append_list_tail(list, (struct List *)process);

    wake_up(1);
    schedule();
}

void wait(void)
{
    struct ProcessControl *process_control;
    struct Process *process;
    struct HeadList *list;

    process_control = get_pc();
    list = &process_control->kill_list;

    while (1)
    {
        if (!is_list_empty(list))
        {
            process = (struct Process *)remove_list_head(list);
            ASSERT(process->state == PROC_KILLED);

            kfree(process->stack);
            free_vm(process->page_map);
            memset(process, 0, sizeof(struct Process));
        }
        else
        {
            sleep(1);
        }
    }
}