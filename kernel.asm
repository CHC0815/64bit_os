[BITS 64]
[ORG 0x200000]

%macro push_state 0
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
%endmacro

%macro pop_state 0
    pop	r15
    pop	r14
    pop	r13
    pop	r12
    pop	r11
    pop	r10
    pop	r9
    pop	r8
    pop	rbp
    pop	rdi
    pop	rsi  
    pop	rdx
    pop	rcx
    pop	rbx
    pop	rax
%endmacro


start:
    mov rdi,Idt
    mov rax,Handler0        ; div by 0 at 1th entry
    call SetHandler

    mov rax,Timer
    mov rdi,Idt+32*16       ; timer at 32th entry
    call SetHandler


    mov rdi, Idt+32*16+7*16
    mov rax, SIRQ
    call SetHandler

    lgdt [Gdt64Ptr]
    lidt [IdtPtr]

SetTss:
    mov rax,Tss
    mov [TssDesc+2],ax
    shr rax,16
    mov [TssDesc+4],al
    shr rax,8
    mov [TssDesc+7],al
    shr rax,8
    mov [TssDesc+8],eax
    mov ax,0x20
    ltr ax

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
    mov al,0x11
    out 0x20,al
    out 0xa0,al

    mov al,32
    out 0x21,al
    mov al,40
    out 0xa1,al

    mov al,4
    out 0x21,al
    mov al,2
    out 0xa1,al

    mov al,1
    out 0x21,al
    out 0xa1,al

    mov al,11111110b
    out 0x21,al
    mov al,11111111b
    out 0xa1,al

    push 0x18|3
    push 0x7c00
    push 0x202              ; interrupt is enabled
    push 0x10|3
    push UserEntry
    iretq

End:
    hlt
    jmp End

SetHandler:
    mov [rdi],ax
    shr rax,16
    mov [rdi+6],ax
    shr rax,16
    mov [rdi+8],eax
    ret

UserEntry:
    ; mov ax, cs
    ; and al, 11b     ; check if we are running in ring 3
    ; cmp al, 3
    ; jne UEnd

    inc byte[0xb8010]
    mov byte[0xb8011], 0xf

UEnd:
    jmp UserEntry        ; cannot hlt because we are in ring 3 --> inf loop

Handler0:
    push_state

    mov byte[0xb8000], 'D'
    mov byte[0xb8001], 0xc

    jmp End

    pop_state

    iretq

Timer:
    push_state

    inc byte[0xb8020]
    mov byte[0xb8021], 0xe

    mov al, 0x20
    out 0x20, al

    pop_state

    iretq

SIRQ:
    push_state

    mov al, 11
    out 0x20, al
    in al, 0x20

    test al, (1<<7)
    jz .end

    mov al, 0x20
    out 0x20, al

.end:                           ; local variable
    pop_state

    iretq

Gdt64:
    dq 0
    dq 0x0020980000000000
    dq 0x0020f80000000000
    dq 0x0000f20000000000
TssDesc:                        ; part of gdt
    dw TssLen-1
    dw 0
    db 0
    db 0x89
    db 0
    db 0
    dq 0

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

Tss:
    dd 0
    dq 0x150000
    times 88 db 0
    dd TssLen

TssLen: equ $-Tss