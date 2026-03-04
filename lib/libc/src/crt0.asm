; crt0.asm - C 运行时启动代码
; x64 Windows 版本

global _start
global exit
extern main
extern __init
extern __fini

section .text

_start:
    ; 设置栈帧
    push rbp
    mov rbp, rsp
    
    ; 获取命令行参数
    mov r12, rcx        ; argc
    mov r13, rdx        ; argv
    
    ; 调用初始化函数
    call __init
    
    ; 调用 main 函数
    mov rcx, r12        ; argc
    mov rdx, r13        ; argv
    call main
    
    ; 保存返回值
    mov r14, rax
    
    ; 调用终结函数
    call __fini
    
    ; 退出程序
    mov rcx, r14
    call exit
    
    ; 永远不会执行到这里
    hlt

; exit 函数
exit:
    push rbp
    mov rbp, rsp
    
    ; Windows 退出系统调用
    mov eax, 0x2000001   ; SYS_exit
    syscall
    
    ; 永远不会执行到这里
    pop rbp
    ret