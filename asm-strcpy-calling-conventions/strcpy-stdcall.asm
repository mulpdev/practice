BITS 32

; ==================================================
; This snippet of code 
;   - Implements strcpy and strlen without a libc
;   - Allocates a page of dynamic memory
;   - copies the string str1 into that memory
; ==================================================


; stdcall 
; - R to L arguments
; - callee cleans stack, no vararg
; - preserve ebx, esi, edi, ebp, esp 
;
; https://github.com/torvalds/linux/blob/v4.17/arch/x86/entry/syscalls/syscall_32.tbl#L17
; https://en.wikibooks.org/wiki/X86_Assembly/Interfacing_with_Linux
; https://github.com/torvalds/linux/blob/v3.13/arch/x86/ia32/ia32entry.S#L99-L117
; 32 bit system calls
;   - eax is syscall number
;   - ebx, ecx, edx, esi, edi, ebp for arguments
;
; sysenter (https://reverseengineering.stackexchange.com/questions/2869/how-to-use-sysenter-under-linux)
; before executing the sysenter instruction, the stack needs to be populated with values:
;   1. push the address of where to return too after the syscall (saved EIP)
;   2. push ecx
;   3. push edx
;   4. push ebp
; 

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

_strlen@4:
  push ebp
  mov ebp, esp
  push ecx
  push edi

  cld
  xor eax,eax
  mov ecx, 0x1000
  mov edx, ecx 
  mov edi, [ebp + 0x8]
  b:
  repne scasb
  je strlen_done

  strlen_done:
  std
  sub edx, ecx
  mov eax, edx
  
  pop edi
  pop ecx
  mov esp, ebp
  pop ebp
  ret 4


; +0xC  param 2 src
; +0x8  param 1 dst
_strcpy@8:
  push ebp
  mov ebp, esp        ; End of prologue, no local vars or clobbered regs

  xor eax,eax

  mov edx, [ebp + 0xC]  ; param 2 src
  push edx
  call _strlen@4

  mov ecx, eax
  mov edx, ecx
  mov edi, [ebp + 0x8]  ; param 1 dst
  mov esi, [ebp + 0xC]  ; param 2 src
  cld
  rep movsb
  std 
  mov esp, ebp
  pop ebp
  ret 8




_start:
  ; void *mmap2(void *addr, size_t length, int prot,
  ;             int flags, int fd, off_t pgoffset);

  ; http://dbp-consulting.com/tutorials/debugging/linuxProgramStartup.html#toc_link7
  xor ebp, ebp
  and esp, 0xfffffff0

  mov ebx, 0
  mov ecx, 4096            ; length < page length (4k) results in a page being allocated anyway
  mov edx, PROT_READ
  or edx, PROT_WRITE       ; R/W permissions
  mov esi, MAP_ANONYMOUS
  or esi, MAP_PRIVATE      ; private and not file backed (just allocate memory, don't make it point to a file)
  mov edi, -1              ; no fd
  mov ebp, 0x0             ; no offset
  mov eax, 192             ; syscall 192 is mmap2, 90 is mmap but fails?
  
  push after_mmap          ; EIP after sysenter
  push ecx
  push edx
  push ebp
  mov ebp, esp
  sysenter

  after_mmap:
  test eax, eax
  jz err

  push str1
  push eax      ; eax is address from mmap
  call _strcpy@8
  xor ecx, ecx
  ; exit
  exit:
  mov eax, 1

  push exit
  push ecx
  push edx
  push ebp
  mov ebp, esp
  sysenter

  ; exit if error
  err:
  mov ebx, -1
  jmp exit
