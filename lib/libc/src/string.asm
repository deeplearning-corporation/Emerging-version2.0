; string.asm - 字符串函数

global strlen
global strcpy
global strncpy
global strcat
global strncat
global strcmp
global strncmp
global strchr
global strrchr
global strstr
global memcpy
global memmove
global memset
global memcmp

section .text

; size_t strlen(const char* s)
strlen:
    push rbp
    mov rbp, rsp
    
    mov rsi, rcx
    xor rax, rax
.loop:
    cmp byte [rsi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    pop rbp
    ret

; char* strcpy(char* dest, const char* src)
strcpy:
    push rbp
    mov rbp, rsp
    push rsi
    push rdi
    
    mov rdi, rcx        ; dest
    mov rsi, rdx        ; src
    mov rax, rdi
    
.loop:
    mov dl, [rsi]
    mov [rdi], dl
    test dl, dl
    jz .done
    inc rsi
    inc rdi
    jmp .loop
.done:
    pop rdi
    pop rsi
    pop rbp
    ret

; char* strncpy(char* dest, const char* src, size_t n)
strncpy:
    push rbp
    mov rbp, rsp
    push rsi
    push rdi
    push rbx
    
    mov rdi, rcx        ; dest
    mov rsi, rdx        ; src
    mov rcx, r8         ; n
    mov rax, rdi
    xor rbx, rbx
    
.loop:
    cmp rbx, rcx
    jge .pad
    mov dl, [rsi + rbx]
    mov [rdi + rbx], dl
    test dl, dl
    jz .pad
    inc rbx
    jmp .loop
    
.pad:
    cmp rbx, rcx
    jge .done
    mov byte [rdi + rbx], 0
    inc rbx
    jmp .pad
    
.done:
    pop rbx
    pop rdi
    pop rsi
    pop rbp
    ret

; char* strcat(char* dest, const char* src)
strcat:
    push rbp
    mov rbp, rsp
    push rsi
    push rdi
    
    mov rdi, rcx        ; dest
    mov rsi, rdx        ; src
    
    ; 找到 dest 末尾
    xor rax, rax
.find_end:
    cmp byte [rdi + rax], 0
    je .copy
    inc rax
    jmp .find_end
    
.copy:
    mov rdi, rdi
    add rdi, rax
    call strcpy
    
    mov rax, rcx
    
    pop rdi
    pop rsi
    pop rbp
    ret

; int strcmp(const char* s1, const char* s2)
strcmp:
    push rbp
    mov rbp, rsp
    
    mov rsi, rcx        ; s1
    mov rdi, rdx        ; s2
    xor rax, rax
    xor rcx, rcx
    
.loop:
    mov al, [rsi + rcx]
    mov dl, [rdi + rcx]
    cmp al, dl
    jne .diff
    test al, al
    jz .equal
    inc rcx
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

; int strncmp(const char* s1, const char* s2, size_t n)
strncmp:
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
    test al, al
    jz .equal
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

; char* strchr(const char* s, int c)
strchr:
    push rbp
    mov rbp, rsp
    
    mov rsi, rcx        ; s
    mov eax, edx        ; c
    xor rcx, rcx
    
.loop:
    mov dl, [rsi + rcx]
    cmp dl, al
    je .found
    test dl, dl
    jz .not_found
    inc rcx
    jmp .loop
    
.found:
    lea rax, [rsi + rcx]
    jmp .done
.not_found:
    xor rax, rax
.done:
    pop rbp
    ret

; void* memcpy(void* dest, const void* src, size_t n)
memcpy:
    push rbp
    mov rbp, rsp
    push rsi
    push rdi
    
    mov rdi, rcx        ; dest
    mov rsi, rdx        ; src
    mov rcx, r8         ; n
    mov rax, rdi
    
    ; 逐字节复制
    rep movsb
    
    pop rdi
    pop rsi
    pop rbp
    ret

; void* memset(void* s, int c, size_t n)
memset:
    push rbp
    mov rbp, rsp
    push rdi
    
    mov rdi, rcx        ; s
    mov eax, edx        ; c
    mov rcx, r8         ; n
    mov rax, rdi
    
    rep stosb
    
    pop rdi
    pop rbp
    ret