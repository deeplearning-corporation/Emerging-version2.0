; file.asm - 文件操作函数

global fopen
global fclose
global fread
global fwrite

extern open
extern close
extern read
extern write
extern lseek
extern malloc
extern free

section .data
    O_RDONLY   equ 0
    O_WRONLY   equ 1
    O_RDWR     equ 2
    O_CREAT    equ 0100o
    O_TRUNC    equ 01000o
    O_APPEND   equ 02000o
    
    SEEK_SET   equ 0
    SEEK_CUR   equ 1
    SEEK_END   equ 2

section .bss
    FILE_size equ 48

section .text

; FILE* fopen(const char* filename, const char* mode)
fopen:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    push rbx
    
    mov rbx, rcx
    mov r12, rdx
    
    xor r13, r13
    xor r14, r14
    
    mov rsi, r12
.parse_mode:
    mov al, [rsi]
    test al, al
    jz .parse_done
    
    cmp al, 'r'
    je .mode_read
    cmp al, 'w'
    je .mode_write
    cmp al, 'a'
    je .mode_append
    cmp al, '+'
    je .mode_plus
    
    inc rsi
    jmp .parse_mode
    
.mode_read:
    or r13, O_RDONLY
    inc rsi
    jmp .parse_mode
.mode_write:
    or r13, O_WRONLY | O_CREAT | O_TRUNC
    inc rsi
    jmp .parse_mode
.mode_append:
    or r13, O_WRONLY | O_CREAT | O_APPEND
    inc rsi
    jmp .parse_mode
.mode_plus:
    and r13, ~(O_RDONLY | O_WRONLY)
    or r13, O_RDWR
    inc rsi
    jmp .parse_mode
    
.parse_done:
    
    mov rcx, rbx
    mov rdx, r13
    mov r8, 0644o
    call open
    
    cmp eax, -1
    je .error
    
    push rax
    mov ecx, FILE_size
    call malloc
    pop rcx
    test rax, rax
    jz .error_close
    
    ret
    
.error_close:
    mov ecx, eax
    call close
.error:
    xor rax, rax
    pop rbx
    add rsp, 32
    pop rbp
    ret