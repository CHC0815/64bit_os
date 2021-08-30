
section .text
extern handler
global vector0
global vector1
global vector2
global vector3
global vector4
global vector5
global vector6
global vector7
global vector8
global vector10
global vector11
global vector12
global vector13
global vector14
global vector16
global vector17
global vector18
global vector19
global vector32
global vector33
global vector39
global sysint
global eoi
global read_isr
global load_idt
global load_cr3
global pstart
global read_cr2
global TrapReturn
global swap
global in_byte


Trap:
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

    mov rdi, rsp
    call handler

TrapReturn:
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    add rsp, 16     ; vector0... has pushed two 8 bit values --> move stack pointer by 16 bits
    iretq





; list: https://wiki.osdev.org/Exceptions
; div by 0
vector0:
    push 0      ; error code
    push 0      ; index
    jmp Trap

vector1:
    push 0
    push 1
    jmp Trap


vector2:
    push 0
    push 2
    jmp Trap

vector3:
    push 0
    push 3	
    jmp Trap 

vector4:
    push 0
    push 4	
    jmp Trap   

vector5:
    push 0
    push 5
    jmp Trap    

vector6:
    push 0
    push 6	
    jmp Trap      

vector7:
    push 0
    push 7	
    jmp Trap  

; double fault
vector8:
    ; error code is pushed by cpu
    push 8      
    jmp Trap  

vector10:
    push 10	
    jmp Trap 

vector11:
    push 11	
    jmp Trap
    
vector12:
    push 12	
    jmp Trap          

vector13:
    push 13	
    jmp Trap
    
vector14:
    push 14	
    jmp Trap 

vector16:
    push 0
    push 16	
    jmp Trap          

vector17:
    push 17	
    jmp Trap                         

vector18:
    push 0
    push 18	
    jmp Trap 

vector19:
    push 0
    push 19	
    jmp Trap

vector32:
    push 0
    push 32
    jmp Trap

vector33:
    push 0
    push 33
    jmp Trap

vector39:
    push 0
    push 39
    jmp Trap

sysint:
    push 0
    push 0x80
    jmp Trap

; end of interrupt
eoi:
    mov al, 0x20
    out 0x20, al
    ret

read_isr:
    mov al, 11
    out 0x20, al
    in al, 0x20
    ret

load_idt:
    lidt [rdi]
    ret

load_cr3:
    mov rax, rdi
    mov cr3, rax
    ret

read_cr2:
    mov rax, cr2
    ret

pstart:
    mov rsp, rdi
    jmp TrapReturn

swap:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    
                        ; change kernel stack pointer to another process
    mov [rdi], rsp      ; rdi the address of context field in process
    mov rsp, rsi        ; rsi the context value in the next process

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx

    ret

in_byte:
    mov rdx, rdi        ; port
    in al, dx           ; move byte in lower eax to return
    ret