global _start

section .text

add_two:
	mov rax, rdi   ; rdi = a
	add rax, rsi
	ret

_start:
	mov rdi, 5
	mov rsi, 2
	call add_two
	
	mov rax, 60
	xor rdi, rdi
	syscall
