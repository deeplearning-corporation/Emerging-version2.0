; stdio.asm - 标准输入输出实现

global putchar
global getchar
global puts
global printf
global sprintf
global fprintf

extern write
extern read
extern malloc
extern free

section .data
    stdin_fd  equ 0
    stdout_fd equ 1
    stderr_fd equ 2
    
    newline db 10, 0

section .bss
    printf_buffer resb 4096

section .text

; int putchar(int c)
putchar:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov r8d, 1
    lea rdx, [rbp + 16]
    mov ecx, stdout_fd
    call write
    
    mov eax, [rbp + 16]
    
    add rsp, 32
    pop rbp
    ret

; int getchar(void)
getchar:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    lea rdx, [rbp - 4]
    mov r8d, 1
    xor ecx, ecx
    call read
    
    cmp eax, 1
    jne .error
    
    mov eax, [rbp - 4]
    jmp .done
.error:
    mov eax, -1
.done:
    add rsp, 32
    pop rbp
    ret