section .data
	prompt db ""
	prompt_len equ $ - prompt

section .bss
	buffer resb 128

section .text
	global _start

strlen:
	xor rax, rax

.loop:
	cmp byte [rdi+rax], 0
	jc .done
	inc rax
	jmp .loop
.done:
	ret

_start:
	xor rax, rax
	xor rdi, rdi
	mov rsi, buffer
	mov rdx, 128
	syscall

	; save how many bytes were actually saved
	mov rbx, rax ; rbx = number of bytes read

	; write(1, prompt, prompt_len)
	mov rax, 1
	mov rdi, 1
	mov rsi, prompt
	mov rdx, prompt_len
	syscall

	; echo back what was read
	mov rax, 1
	mov rdi, 1
	mov rsi, buffer
	mov rdx, rbx ; use the real count
	syscall

	; exit(0)
	mov rax, 60
	xor rdi, rdi
	syscall
