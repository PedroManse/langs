format ELF64 executable 3
entry start
use64

; fn/syscall parameters order:
; eax	; syscall_number
; rdi	; 1st param
; rsi	; 2nd param
; rdx	; 3rd param
; r10	; 4th param
; r8	; 5th param
; r9	; 6th param

stdin = 0
stdout = 1
stderr = 2

sysint = 0x80
sys.read = 0
sys.write = 1
sys.open = 2
sys.close = 3
sys.exit = 60

segment readable executable
start:
  mov eax,sys.write
  mov rdi,stdout
  mov rsi,msg           ; Address of message
  mov rdx,msg_size      ; Length  of message
	syscall

  mov eax,sys.exit             ; System call 'exit'
  mov rdi,0             ; Exitcode: 0
	syscall

segment readable writeable
msg db 'Hello world',0xA
msg_size = $-msg


; thank you SO MUCH https://stackoverflow.com/a/58667893
