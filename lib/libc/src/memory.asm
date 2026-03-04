; memory.asm - 内存管理函数

global memchr
global memcmp
global memcpy
global memmove
global memset

section .text

; void* memchr(const void* s, int c, size_t n)
memchr:
    push rbp
    mov rbp, rsp
    
    mov rsi, rcx        ; s
    mov eax, edx        ; c
    mov rcx, r8         ; n
    xor r9, r9
    
.loop:
    cmp r9, rcx
    jge .not_found
    cmp al, [rsi + r9]
    je .found
    inc r9
    jmp .loop
    
.found:
    lea rax, [rsi + r9]
    jmp .done
.not_found:
    xor rax, rax
.done:
    pop rbp
    ret

; int memcmp(const void* s1, const void* s2, size_t n)
memcmp:
    push rbp
    mov rbp, rsp
    
    mov rsi, rcx        ; s1
    mov rdi, rdx        ; s2
    mov rcx, r8         ; n
    xor rax, rax
    xor r9, r9
    
.loop:
    cmp r9, rcx
    jge .equal
    mov al, [rsi + r9]
    mov dl, [rdi + r9]
    cmp al, dl
    jne .diff
    inc r9
    jmp .loop
    
.diff:
    movzx eax, al
    movzx edx, dl
    sub eax, edx
    jmp .done
.equal:
    xor eax, eax
.done:
    pop rbp
    ret

; void* memmove(void* dest, const void* src, size_t n)
memmove:
    push rbp
    mov rbp, rsp
    push rsi
    push rdi
    
    mov rdi, rcx        ; dest
    mov rsi, rdx        ; src
    mov rcx, r8         ; n
    mov rax, rdi
    
    ; 检查重叠
    cmp rdi, rsi
    jae .reverse
    
    ; 正向复制
    rep movsb
    jmp .done
    
.reverse:
    ; 反向复制
    add rsi, rcx
    add rdi, rcx
    dec rsi
    dec rdi
    std
    rep movsb
    cld
    
.done:
    pop rdi
    pop rsi
    pop rbp
    ret