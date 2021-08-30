section .text
global writeu
global sleepu

writeu:
    sub rsp, 16         ; allocate space 
    xor eax, eax        ; index 0

    mov [rsp], rdi      ; char* buffer
    mov [rsp+8], rsi    ; int buffer_size

    mov rdi, 2  ; 2 arguments
    mov rsi, rsp
    int 0x80            ; software interrupt --> handeled in trap.c --> syscall.c

    add rsp, 16
    ret

sleepu:
    sub rsp, 8      ; one parameter 
    mov eax, 1      ; index 1
    
    mov [rsp], rdi
    mov rdi, 1
    mov rsi, rsp

    int 0x80
    
    add rsp, 8
    ret