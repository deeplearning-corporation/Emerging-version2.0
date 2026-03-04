; runtime.asm - Emerging 2.0 Runtime Library
; x64 Windows 版本
; 汇编: nasm -f win64 -o runtime.obj runtime.asm

section .data
    newline db 13, 10, 0
    msg_hello db "Emerging Runtime Loaded", 13, 10, 0

section .text
    global out
    global out_num
    global out_char
    global create
    global textfile
    global copyfile
    global syscmd
    global disk_read
    global disk_write
    global hardware_port_out
    global hardware_port_in
    global hardware_interrupt

; 外部 Windows API
extern GetStdHandle
extern WriteConsoleA
extern ReadConsoleA
extern CreateFileA
extern WriteFile
extern ReadFile
extern CloseHandle
extern system
extern ExitProcess

; ====================================================
; void out(const char* str)
; ====================================================
out:
    push rbp
    mov rbp, rsp
    sub rsp, 32          ; 影子空间
    
    ; 获取标准输出句柄
    mov ecx, -11         ; STD_OUTPUT_HANDLE
    call GetStdHandle
    
    ; 计算字符串长度
    mov rdx, [rbp + 16]  ; 字符串指针
    xor r8, r8           ; 长度计数器
.len_loop:
    cmp byte [rdx + r8], 0
    jz .len_done
    inc r8
    jmp .len_loop
.len_done:
    
    ; 调用 WriteConsoleA
    mov rcx, rax         ; 句柄
    mov rdx, [rbp + 16]  ; 缓冲区
    mov r9, 0            ; lpReserved
    lea rax, [rsp + 16]  ; lpNumberOfCharsWritten
    push rax
    push r9
    sub rsp, 32
    call WriteConsoleA
    add rsp, 32+16
    
    add rsp, 32
    pop rbp
    ret

; ====================================================
; void out_num(int num)
; ====================================================
out_num:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    mov eax, [rbp + 16]  ; 数字
    lea rdi, [rsp + 32]  ; 缓冲区
    mov ecx, 10
    mov r8d, eax
    
    test eax, eax
    jnz .convert
    mov byte [rdi], '0'
    inc rdi
    jmp .print
    
.convert:
    test eax, eax
    jns .positive
    neg eax
.positive:
    xor edx, edx
    div ecx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test eax, eax
    jnz .positive
    
    test r8d, r8d
    jns .print
    dec rdi
    mov byte [rdi], '-'
    
.print:
    mov rcx, rdi
    call out
    
    add rsp, 64
    pop rbp
    ret

; ====================================================
; void out_char(char c)
; ====================================================
out_char:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    movzx ecx, byte [rbp + 16]
    push rcx
    call out_num
    add rsp, 8
    
    add rsp, 32
    pop rbp
    ret

; ====================================================
; int create(const char* path)
; ====================================================
create:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, [rbp + 16]  ; lpFileName
    mov edx, 0x40000000  ; GENERIC_WRITE
    xor r8, r8           ; dwShareMode
    xor r9, r9           ; lpSecurityAttributes
    push 2               ; CREATE_ALWAYS
    push 0x80            ; FILE_ATTRIBUTE_NORMAL
    push 0               ; hTemplateFile
    sub rsp, 32
    call CreateFileA
    add rsp, 32+24
    
    cmp rax, -1
    je .error
    
    mov rcx, rax
    call CloseHandle
    mov eax, 0
    jmp .done
.error:
    mov eax, -1
.done:
    add rsp, 32
    pop rbp
    ret

; ====================================================
; int textfile(const char* content)
; ====================================================
textfile:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; 这里简化实现，实际需要文件名参数
    ; 暂时输出到控制台
    mov rcx, [rbp + 16]
    call out
    
    mov eax, 0
    add rsp, 32
    pop rbp
    ret

; ====================================================
; int copyfile(const char* src, const char* dest)
; ====================================================
copyfile:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; 简化实现
    mov eax, 0
    add rsp, 32
    pop rbp
    ret

; ====================================================
; int syscmd(const char* cmd)
; ====================================================
syscmd:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov rcx, [rbp + 16]
    call system
    
    add rsp, 32
    pop rbp
    ret

; ====================================================
; int disk_read(int sector, void* buffer, int count)
; ====================================================
disk_read:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; 模拟磁盘读取
    mov eax, 0
    
    add rsp, 32
    pop rbp
    ret

; ====================================================
; int disk_write(int sector, void* buffer, int count)
; ====================================================
disk_write:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov eax, 0
    
    add rsp, 32
    pop rbp
    ret

; ====================================================
; void hardware_port_out(int port, byte data)
; ====================================================
hardware_port_out:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov edx, [rbp + 16]  ; port
    mov al, [rbp + 20]   ; data
    out dx, al
    
    add rsp, 32
    pop rbp
    ret

; ====================================================
; byte hardware_port_in(int port)
; ====================================================
hardware_port_in:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov edx, [rbp + 16]  ; port
    xor eax, eax
    in al, dx
    
    add rsp, 32
    pop rbp
    ret

; ====================================================
; void hardware_interrupt(int num)
; ====================================================
hardware_interrupt:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    mov eax, [rbp + 16]
    ; int eax  ; 触发中断
    
    add rsp, 32
    pop rbp
    ret

; ====================================================
; 程序入口点（如果需要）
; ====================================================
global _start
_start:
    sub rsp, 32
    lea rcx, [msg_hello]
    call out
    add rsp, 32
    xor ecx, ecx
    call ExitProcess