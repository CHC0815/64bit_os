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

LoadUser:
    mov si, ReadPacket
    mov word[si], 0x10      ; size 16 bytes
    mov word[si+2], 10      ; number of sectors
    mov word[si+4], 0       ; offset
    mov word[si+6], 0x2000  ; segment
    mov dword[si+8], 106    ; address lo
    mov dword[si+0xc], 0    ; address hi
    mov dl, [DriveId]
    mov ah, 0x42
    int 0x13
    jc ReadError

LoadUser2:
    mov si, ReadPacket
    mov word[si], 0x10      ; size 16 bytes
    mov word[si+2], 10      ; number of sectors
    mov word[si+4], 0       ; offset
    mov word[si+6], 0x3000  ; segment
    mov dword[si+8], 116    ; address lo
    mov dword[si+0xc], 0    ; address hi
    mov dl, [DriveId]
    mov ah, 0x42
    int 0x13
    jc ReadError

GetMemInfoStart:
    mov eax, 0xe820
    mov edx, 0x534d4150
    mov ecx, 20
    mov dword[0x9000], 0
    mov edi, 0x9008
    xor ebx, ebx
    int 0x15
    jc NotSupport

GetMemInfo:
    add edi, 20
    inc dword[0x9000]
    test ebx, ebx
    jz GetMemDone

    mov eax, 0xe820
    mov edx, 0x534d4150
    mov ecx, 20
    int 0x15
    jnc GetMemInfo

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

    cli             ; clear interrupt flag

    lgdt [Gdt32Ptr] ; load global descriptor table
    lidt [Idt32Ptr] ; load interrupt descriptor table

    mov eax, cr0
    or eax, 1
    mov cr0, eax    ; enable protected mode

    jmp 8:PMEntry

ReadError:
NotSupport:
End:
    hlt
    jmp End

; ----------------------------------------------------------------------------------------------------------
[BITS 32]
PMEntry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7c00

    cld
    mov edi, 0x70000
    xor eax, eax
    mov ecx, 0x10000/4
    rep stosd

    mov dword[0x70000], 0x71003
    mov dword[0x71000], 10000011b

    mov eax, (0xffff800000000000>>39)           ; get 9 bit index value
    and eax, 0x1ff
    mov dword[0x70000+eax*8], 0x72003
    mov dword[0x72000], 10000011b



    lgdt [Gdt64Ptr]
    mov eax, cr4
    or eax, (1<<5)
    mov cr4, eax

    mov eax, 0x70000
    mov cr3, eax

    mov ecx, 0xc0000080
    rdmsr
    or eax, (1<<8)
    wrmsr

    mov eax, cr0
    or eax, (1<<31)
    mov cr0, eax

    jmp 8:LMEntry

PEnd:
    hlt
    jmp PEnd

; -------------------------------------------------------------------------------------------------------------
[BITS 64]
LMEntry:
    mov rsp, 0x7c00
    
    ; move kernel to 0x200000
    cld
    mov rdi, 0x200000
    mov rsi, 0x10000
    mov rcx, 51200/8
    rep movsq                   ; repeat movsq, counter rcx, from rdi to rsi

    mov rax,0xffff800000200000
    jmp rax

LEnd:
    hlt
    jmp LEnd

DriveId: db 0
ReadPacket: times 16 db 0       ; 0 size, 2 number of sectors, 4 offset, 6 segment, 8 address lo, 14 address hi

Gdt32:
    dq 0
Code32:
    dw 0xffff
    dw 0
    db 0
    db 0x9a
    db 0xcf
    db 0
Data32:
    dw 0xffff
    dw 0
    db 0
    db 0x92
    db 0xcf
    db 0

Gdt32PtrLen: equ $-Gdt32

Gdt32Ptr: dw Gdt32PtrLen-1
          dd Gdt32

Idt32Ptr: dw 0
          dd 0

Gdt64:
    dq 0
    dq 0x0020980000000000

Gdt64Len: equ $-Gdt64

Gdt64Ptr: dw Gdt64Len-1
          dd Gdt64