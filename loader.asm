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

LoadKernel:
    mov si, ReadPacket
    mov word[si], 0x10      ; size 16 bytes
    mov word[si+2], 100     ; number of sectors
    mov word[si+4], 0       ; offset
    mov word[si+6], 0x1000  ; segment       --> 0x1000:0 = 0x1000*16+0 = 0x10000
    mov dword[si+8], 6      ; address lo
    mov dword[si+0xc], 0    ; address hi
    mov dl, [DriveId]
    mov ah, 0x42
    int 0x13
    jc ReadError

    mov ah, 0x13
    mov al, 1
    mov bx, 0xa
    xor dx, dx
    mov bp, Message
    mov cx, MessageLen
    int 0x10

ReadError:
NotSupport:
End:
    hlt
    jmp End

DriveId: db 0
Message: db "Kernel is loaded!"
MessageLen: equ $-Message
ReadPacket: times 16 db 0       ; 0 size, 2 number of sectors, 4 offset, 6 segment, 8 address lo, 14 address hi