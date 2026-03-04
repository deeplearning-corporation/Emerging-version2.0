; syscall.asm - 系统调用封装

global syscall
global read
global write
global open
global close
global lseek
global unlink
global rename
global getpid
global exit
global sbrk
global gettimeofday
global sleep

section .text

; 通用系统调用
syscall:
    mov rax, rcx
    syscall
    ret

; ssize_t read(int fd, void* buf, size_t count)
read:
    mov eax, 0         ; SYS_read
    syscall
    ret

; ssize_t write(int fd, const void* buf, size_t count)
write:
    mov eax, 1         ; SYS_write
    syscall
    ret

; int open(const char* pathname, int flags, mode_t mode)
open:
    mov eax, 2         ; SYS_open
    syscall
    ret

; int close(int fd)
close:
    mov eax, 3         ; SYS_close
    syscall
    ret

; off_t lseek(int fd, off_t offset, int whence)
lseek:
    mov eax, 8         ; SYS_lseek
    syscall
    ret

; int unlink(const char* pathname)
unlink:
    mov eax, 10        ; SYS_unlink
    syscall
    ret

; int rename(const char* oldpath, const char* newpath)
rename:
    mov eax, 38        ; SYS_rename
    syscall
    ret

; pid_t getpid(void)
getpid:
    mov eax, 39        ; SYS_getpid
    syscall
    ret

; void _exit(int status)
exit:
    mov eax, 60        ; SYS_exit
    syscall
    ret

; void* sbrk(intptr_t increment)
sbrk:
    mov eax, 12        ; SYS_brk
    syscall
    ret

; int gettimeofday(struct timeval* tv, struct timezone* tz)
gettimeofday:
    mov eax, 96        ; SYS_gettimeofday
    syscall
    ret

; unsigned int sleep(unsigned int seconds)
sleep:
    mov eax, 35        ; SYS_nanosleep
    ; 简化实现
    syscall
    ret