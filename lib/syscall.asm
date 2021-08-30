section .text
global writeu
global sleepu
global exitu
global waitu
global keyboard_readu
global get_total_memoryu

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

exitu:
    mov eax, 2      ; index 2
    mov rdi, 0      ; no args

    int 0x80

    ret

waitu:
    mov eax, 3      ; index 3
    mov rdi, 0      ; no args

    int 0x80

    ret

keyboard_readu:
    mov eax, 4
    mov rdi, 0

    int 0x80

    ret

get_total_memoryu:
    mov eax, 5
    mov rdi, 0

    int 0x80

    ret