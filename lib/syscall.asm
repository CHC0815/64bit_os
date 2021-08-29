section .text
global writeu

writeu:
    sub rsp, 16         ; allocate space 
    xor eax, eax

    mov [rsp], rdi      ; char* buffer
    mov [rsp+8], rsi    ; int buffer_size

    mov rdi, 2  ; 2 arguments
    mov rsi, rsp
    int 0x80            ; software interrupt --> handeled in trap.c --> syscall.c

    add rsp, 16
    ret