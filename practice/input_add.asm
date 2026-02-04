section .data
	prompt db ""
	prompt_len equ $ - prompt

section .bss
	buffer resb 128   ; reserve 128 bytes (uninitialized)

section .text
	global _start


;input: rdi = a,  rsi = b
;output: rax = integer value
add:
	xor rax, rax  ; zeros the reg
	mov rax, rdi  ; rdi = a
	add rax, rsi  ; rsi = b
	ret

subtract:
	xor rax, rax  ; zeros the reg
	mov rax, rdi  ; rdi = a
	sub rax, rsi  ; rsi = b
	ret

divide:
	mov xmm0, rdi
	idiv xmm0, rsi
	ret

multiply:
	xor rax, rax   ; zeros the reg
	mov rax, rdi
	imul rax, rsi
	ret

;input: rdi = pointer to string (null-terminated or stops at non-digit)
;output: rax = integer value
str_to_int:
	xor rax, rax
.loop;
	movzx rcx, byte [rdi] ; load next char
	cmp rcx, '0'
	jb .done
	cmp rcx, '9'
	ja .done
	sub rcx, '0'   ; convert ASCII to digit 0-9
	imul rax, rax, 10   ; result *= 10
	add rax, rcx  ; result += digit
	inc rdi
	jmp .loop
.done:
	ret

; input: integer value
; output: same number as a string
int_to_str:
	push rbx
	push r12
	mov rbx, rdi    ; save buffer start
	mov r12, rdi    ; current write position
	
	; handle negative
	test rax, rax
	jns .positive
	mov byte [r12], '-'
	inc r12
	neg rax   ; rax = abs(rax)

.positive:
	mov r9, 10
	
	; Special case: zero
	test rax, rax
	jnz .convert
	mov byte [r12], '0'
	inc r12
	jmp .finish

.convert:
	xor rdx, rdx
	div r9             ; rax = quotient, rdx = reminder (0-9)
	add dl, '0'
	mov byte [r12], dl
	inc r12
	test rax, rax
	jnz .convert
	
	; reverse the digits
	mov rsi, rbx      ; start (may include '-')
	cmp byte [rbx], '-'
	jne .no_sign
	inc rsi           ; skip sign for reversal
.no_sign:
	mov rdi, r12
	dec rdi   ; point to last digit

.reverse:
	cmp rsi, rdi
	jge .reverse_done
	mov al, [rsi]
	mov cl, [rdi]
	mov [rsi], cl
	mov [rdi], al
	inc rsi
	dec rdi
	jmp .reverse

.reverse_done:
	mov byte [r12], 0   ; null-terminate
	mov rax, rbx        ; return buffer pointer
	mov rdx, r12        
	sub rdx, rbx        ; length (includes sign if present)

.finish:
	pop r12
	pop rbx
	ret


strlen: ;find length of null terminated strings
	xor rax, rax
.loop:
	cmp byte [rdi+rax], 0
	je .done
	inc rax
	jmp .loop
.done:
	ret
	

; input: rdi = expression as a string
; process: loops through the expression until it finds a operator
; output: rax = different number for each operation
get_operation:
	
