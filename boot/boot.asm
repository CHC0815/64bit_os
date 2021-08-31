[BITS 16]
[ORG 0x7c00]

start:
    xor ax,ax   
    mov ds,ax
    mov es,ax  
    mov ss,ax
    mov sp,0x7c00

TestDiskExtension:
    mov [DriveId], dl
    mov ah, 0x41
    mov bx, 0x55aa
    int 0x13
    jc NotSupport   ; jump if carry is set
    cmp bx, 0xaa55
    jne NotSupport  ; jump if not equal

LoadLoader:
    mov si, ReadPacket
    mov word[si], 0x10      ; size 16 bytes
    mov word[si+2], 15      ; number of sectors
    mov word[si+4], 0x7e00  ; offset
    mov word[si+6], 0       ; segment 
    mov dword[si+8], 1      ; address lo
    mov dword[si+0xc], 0    ; address hi
    mov dl, [DriveId]
    mov ah, 0x42
    int 0x13
    jc ReadError
    
    mov dl, [DriveId]
    jmp 0x7e00              ; here is the loader file

ReadError:
NotSupport:
    mov ah, 0x13
    mov al, 1
    mov bx, 0xa
    xor dx, dx
    mov bp, Message
    mov cx, MessageLen
    int 0x10

End:
    hlt
    jmp End


DriveId: db 0
Message: db "We have an error in boot process"
MessageLen: equ $-Message
ReadPacket: times 16 db 0       ; 0 size, 2 number of sectors, 4 offset, 6 segment, 8 address lo, 14 address hi

times (0x1be-($-$$)) db 0
    db 80h                      ; boot indicator
    db 1, 1, 0                  ; starting chs
    db 06h                      ; type
    db 0fh, 03fh, 0cah          ; ending chs
    dd 3fh                      ; starting sector
    dd 031f11h                  ; size

    times (16*3) db 0

    db 0x55
    db 0xaa