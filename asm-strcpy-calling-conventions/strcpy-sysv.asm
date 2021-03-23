; ==================================================
; This snippet of code 
;   - Implements strcpy and strlen without a libc
;   - Allocates a page of dynamic memory
;   - copies the string str1 into that memory
; ==================================================


; System V (e.g., x86_64) calling conventions
;
; Appendix A.2.1 Linux Conventions (https://refspecs.linuxfoundation.org/elf/x86_64-abi-0.99.pdf)
; Kernel: %rdi, %rsi, %rdx, %r10, %r8, %r9 
;   - %rax is yscall number
;   - syscall instruction
; User:   %rdi, %rsi, %rdx, %rcx, %r8, %r9
; Preserved: %rbx, %rsp, %rbp, %r12-%r15 (general purpose only) (Figure 3.14)

; https://elixir.bootlin.com/linux/latest/source/include/uapi/asm-generic/mman-common.h#L23 
%define PROT_READ 0x1
%define PROT_WRITE 0x2
%define MAP_ANONYMOUS 0x20
; https://elixir.bootlin.com/linux/latest/source/include/uapi/linux/mman.h#L17
%define MAP_PRIVATE 0x2

section .data
str1: db 'this is only a test', 0

section   .text
global    _start

strlen:
  xor rax, rax
  cld            ; increment rsi/rdi during REP
  mov r8, 0x1000 ; same size as mmap
  mov rcx, r8    
  repne scasb
  je strlen_done
  
  strlen_done:
  std          ; decrement rsi/rdi during REP
  sub r8, rcx
  mov rax, r8
  ret

strcpy:
  xor rax, rax

  mov r12, rdi
  mov rdi, rsi
  call strlen

  mov rcx, rax
  mov rdi, r12
  cld            ; increment rsi/rdi during REP
  rep movsb
  std            ; decrement rsi/rdi during REP
  ret


_start:
  ; void *mmap2(void *addr, size_t length, int prot,
  ;             int flags, int fd, off_t pgoffset);
  mov rdi, 0
  mov rsi, 4096           ; length < page length (4k) results in a page being allocated anyway
  mov rdx, PROT_READ
  or rdx, PROT_WRITE      ; R/W permissions
  mov r10, MAP_ANONYMOUS
  or r10, MAP_PRIVATE     ; private and not file backed (just allocate memory, don't make it point to a file)
  mov r8, -1              ; no fd
  mov r9, 0x0             ; no offset
  mov rax, 9              ; syscall 9 is mmap
  syscall

  cmp rax, 0
  jle err

  mov rdi, rax      ; rax is address from mmap
  mov rsi, str1
  call strcpy

  xor rdi, rdi
  
  ; exit
  exit:
  mov rax, 60
  syscall

  ; exit if error
  err:
  mov rdi, -1
  jmp exit
