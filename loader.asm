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

GetMemInfoStart:
    mov eax, 0xe820
    mov edx, 0x534d4150
    mov ecx, 20
    mov edi, 0x9000
    xor ebx, ebx
    int 0x15
    jc NotSupport

GetMemInfo:
    add edi, 20
    mov eax, 0xe820
    mov edx, 0x534d4150
    mov ecx, 20
    int 0x15
    jc GetMemDone

    test ebx, ebx
    jnz GetMemInfo

GetMemDone:

TestA20:
    mov ax, 0xffff
    mov es, ax
    ; if A20 line is disabled 0x7c00 and 0x107c00 would be the same 
    mov word[ds:0x7c00], 0xa200     ; --> 0:0x7c00 = 0 * 16 + 0x7c00 = 0x7c00
    cmp word[es:0x7c10], 0xa200     ; --> 0xffff:0x7c10 = 0xffff * 16 + 0x7c10 = 0x107c00
    jne SetA20LineDone
    ; first check could be lucky so second check for safety
    mov word[0x7c00], 0xb200
    cmp word[es:0x7c10], 0xb200
    je End


SetA20LineDone:
    xor ax, ax
    mov es, ax      ; reset es after TestA20
    
SetVideoMode:
    mov ax, 3       ; set text mode
    int 0x10

    mov si, Message
    mov ax, 0xb800  ; text buffer
    mov es, ax
    xor di, di
    mov cx, MessageLen

PrintMessage:
    mov al, [si]
    mov [es:di], al
    mov byte[es:di+1], 0xa  ; bright green

    add di, 2               ; index
    add si, 1
    loop PrintMessage       ; ecx (cx) is counter variable with length



ReadError:
NotSupport:
End:
    hlt
    jmp End

DriveId: db 0
Message: db "Text mode is set"
MessageLen: equ $-Message
ReadPacket: times 16 db 0       ; 0 size, 2 number of sectors, 4 offset, 6 segment, 8 address lo, 14 address hi