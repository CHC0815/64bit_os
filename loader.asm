[BITS 16]
[ORG 0x7e00]        ; 512 bytes later -> +0x200

start:
    mov [DriveId], dl

    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb NotSupport           ; jump if not support
    mov eax, 0x80000001     ; check for long mode support
    cpuid
    test edx, (1<<29)       ; test 29th bit
    jz NotSupport           ; jump if not zero
    test edx, (1<<26)
    jz NotSupport

    mov ah, 0x13
    mov al, 1
    mov bx, 0xa
    xor dx, dx
    mov bp, Message
    mov cx, MessageLen
    int 0x10

NotSupport:
End:
    hlt
    jmp End

DriveId: db 0
Message: db "Long mode is supported!"
MessageLen: equ $-Message