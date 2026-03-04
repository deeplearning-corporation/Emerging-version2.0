; time.asm - 时间函数

global time
global clock
global difftime

extern gettimeofday
extern localtime_r
extern sprintf

section .data
    wday_names db "Sun",0,"Mon",0,"Tue",0,"Wed",0,"Thu",0,"Fri",0,"Sat",0
    mon_names db "Jan",0,"Feb",0,"Mar",0,"Apr",0,"May",0,"Jun",0,
              db "Jul",0,"Aug",0,"Sep",0,"Oct",0,"Nov",0,"Dec",0

section .bss
    printf_buffer resb 256
    tm_buffer resb 56
    timeval_tv_sec resq 1
    timeval_tv_usec resq 1

section .text

; time_t time(time_t* tloc)
time:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    lea rcx, [timeval_tv_sec]
    xor rdx, rdx
    call gettimeofday
    
    mov rax, [timeval_tv_sec]
    
    test rcx, rcx
    jz .done
    mov [rcx], rax
.done:
    add rsp, 32
    pop rbp
    ret