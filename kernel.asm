[BITS 64]
[ORG 0x200000]

start:
    mov rdi, Idt
    mov rax, Handler0       ; div by 0 at 1th entry

    mov [rdi], ax
    shr rax, 16
    mov [rdi+6], ax
    shr rax, 16
    mov [rdi+8], rax

    mov rax, Timer
    add rdi, 32*16          ; timer at 32th entry
    mov [rdi], ax
    shr rax, 16
    mov [rdi+6], ax
    shr rax, 16
    mov [rdi+8], rax

    lgdt [Gdt64Ptr]
    lidt [IdtPtr]

    push 8
    push KernelEntry
    db 0x48
    retf

KernelEntry:
    mov byte[0xb8000], 'K'
    mov byte[0xb8001], 0xa


InitPIT:
    mov al, (1<<2) | (3<<4)
    out 0x43, al
    ; 1193182 Hz --> 100Hz --> 11931
    mov ax, 11931
    out 0x40, al    ; low byte
    mov al, ah
    out 0x40, al    ; high byte

InitPIC:
    mov al, 0x11
    out 0x20, al
    out 0xa0, al

    mov al, 32
    out 0x21, al
    mov al, 40
    out 0xa1, al

    mov al, 4
    out 0x21, al
    mov al, 2
    out 0xa1, al

    mov al, 1
    out 0x21, al
    out 0xa1, al

    mov al, 11111110b
    out 0x21, al
    mov al, 11111111b
    out 0xa1, al

    sti


End:
    hlt
    jmp End


Handler0:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov byte[0xb8000], 'D'
    mov byte[0xb8001], 0xc

    jmp End

    push r15
    push r14
    push r13
    push r12
    push r11
    push r10
    push r9
    push r8
    push rbp
    push rsi
    push rdx
    push rcx
    push rbx
    push rax

    iretq

Timer:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov byte[0xb8010], 'T'
    mov byte[0xb8011], 0xe

    jmp End

    push r15
    push r14
    push r13
    push r12
    push r11
    push r10
    push r9
    push r8
    push rbp
    push rsi
    push rdx
    push rcx
    push rbx
    push rax

    iretq

Gdt64:
    dq 0
    dq 0x0020980000000000

Gdt64Len: equ $-Gdt64

Gdt64Ptr: dw Gdt64Len-1
          dq Gdt64

Idt:
    %rep 256
        dw 0
        dw 0x8
        db 0
        db 0x8e
        dw 0
        dd 0
        dd 0
    %endrep

IdtLen: equ $-Idt

IdtPtr: dw IdtLen-1
        dq Idt