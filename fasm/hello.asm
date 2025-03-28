format ELF executable 3
entry start
  use64

; parameters order:
; r9	; 6th param
; r8	; 5th param
; r10	; 4th param
; rdx	; 3rd param
; rsi	; 2nd param
; rdi	; 1st param
; eax	; syscall_number
; syscall

stdin = 0
stdout = 1
stderr = 2

sysint = 0x80
sys.read = 0
sys.write = 1
sys.open = 2
sys.close = 3

segment readable executable
start:
  mov eax,4
  mov ebx,stdout
  mov ecx,msg           ; Address of message
  mov edx,msg_size      ; Length  of message
  int sysint

  mov eax,1             ; System call 'exit'
  mov ebx,0             ; Exitcode: 0
  int 0x80

segment readable writeable
msg db 'Hello world!',0xA
msg_size = $-msg
