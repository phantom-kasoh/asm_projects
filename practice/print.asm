global _start

section .data
	msg db "print function test", 10, 0

section .text


strlen:
	xor rax, rax

.loop:
	cmp byte [rdi+rax], 0
	je .done
	inc rax
	jmp .loop
.done:
	ret



print:
	push rbp
	mov rbp, rsp
	
	push rdi
	
	call strlen

	pop rsi
	mov rdx, rax
	mov rdi, 1
	mov rax, 1
	syscall
	
	pop rbp
	ret

_start:
	mov rdi, msg
	call print

	mov rax, 60
	xor rdi, rdi
	syscall

