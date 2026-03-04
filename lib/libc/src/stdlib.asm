; stdlib.asm - 标准库函数

global atoi
global itoa
global abort
global exit
global malloc
global free
global calloc
global realloc
global system
global rand
global srand

extern sbrk
extern _exit

section .data
    seed dd 1
    
    ; 数字转换表
    digits db "0123456789ABCDEF", 0

section .text

; int atoi(const char* str)
atoi:
    push rbp
    mov rbp, rsp
    
    mov rsi, rcx        ; str
    xor rax, rax        ; result
    xor rcx, rcx        ; sign
    mov cl, 1           ; 默认正号
    
    ; 跳过空白
.skip_ws:
    mov dl, [rsi]
    cmp dl, ' '
    je .next
    cmp dl, 9
    je .next
    cmp dl, 10
    je .next
    cmp dl, 13
    je .next
    jmp .check_sign
.next:
    inc rsi
    jmp .skip_ws
    
.check_sign:
    mov dl, [rsi]
    cmp dl, '-'
    jne .check_plus
    mov cl, -1
    inc rsi
    jmp .convert
.check_plus:
    cmp dl, '+'
    jne .convert
    inc rsi
    
.convert:
    mov dl, [rsi]
    test dl, dl
    jz .done
    
    cmp dl, '0'
    jb .done
    cmp dl, '9'
    ja .done
    
    sub dl, '0'
    imul rax, 10
    add rax, rdx
    inc rsi
    jmp .convert
    
.done:
    imul rax, rcx
    pop rbp
    ret

; char* itoa(int value, char* buffer, int base)
itoa:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    mov eax, ecx        ; value
    mov r12, rdx        ; buffer
    mov ebx, r8d        ; base
    
    cmp ebx, 2
    jl .base_10
    cmp ebx, 16
    jg .base_10
    
    mov r8, r12
    add r8, 32
    mov byte [r8], 0
    dec r8
    
    test eax, eax
    jnz .convert_loop
    mov byte [r8], '0'
    jmp .done
    
.convert_loop:
    xor edx, edx
    div ebx
    mov dl, [digits + rdx]
    mov [r8], dl
    dec r8
    test eax, eax
    jnz .convert_loop
    
    inc r8
.done:
    mov rax, r8
    
    pop r12
    pop rbx
    pop rbp
    ret

.base_10:
    ; 默认基数为10
    mov ebx, 10
    jmp .convert_loop

; void abort(void)
abort:
    push rbp
    mov rbp, rsp
    
    mov ecx, 1
    call _exit
    
    pop rbp
    ret

; void* malloc(size_t size)
malloc:
    push rbp
    mov rbp, rsp
    
    mov rcx, [rbp + 16]
    call sbrk
    
    pop rbp
    ret

; void free(void* ptr)
free:
    ; 简单实现，不释放
    ret

; void* calloc(size_t nmemb, size_t size)
calloc:
    push rbp
    mov rbp, rsp
    
    mov rax, rcx
    imul rax, rdx       ; nmemb * size
    push rax
    call malloc
    pop rcx
    
    ; 清零内存
    mov rdi, rax
    xor eax, eax
    mov rcx, r8
    rep stosb
    
    pop rbp
    ret

; void* realloc(void* ptr, size_t size)
realloc:
    push rbp
    mov rbp, rsp
    
    ; 简化实现：分配新内存，复制旧数据
    push rdx            ; size
    push rcx            ; ptr
    call malloc
    pop rcx
    pop r8
    
    ; 这里应该复制数据
    ; 简化：不复制
    
    pop rbp
    ret

; int system(const char* command)
system:
    push rbp
    mov rbp, rsp
    
    ; 在 Windows 上调用 CreateProcess
    ; 简化：返回错误
    mov eax, -1
    
    pop rbp
    ret

; int rand(void)
rand:
    push rbp
    mov rbp, rsp
    
    mov eax, [seed]
    imul eax, 1103515245
    add eax, 12345
    mov [seed], eax
    shr eax, 16
    and eax, 0x7FFF
    
    pop rbp
    ret

; void srand(unsigned int seed)
srand:
    push rbp
    mov rbp, rsp
    
    mov [seed], ecx
    
    pop rbp
    ret