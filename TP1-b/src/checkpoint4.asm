extern malloc
extern free
extern fprintf

section .data
formato db "%s ", 0

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; a = [rdi], b =[rsi]
strCmp:
	push rbp
	mov rbp,rsp
	xor rax,rax ;res

	.loop:
		mov dl, [rdi] ;a
		mov cl, [rsi] ;b
		cmp dl,cl ; a - b
		jne .desempate
		cmp dl,0 ;si las dos son iguales y son 0 termina la cadena
		je .fin
		inc rdi ;paso al siguiente caracter
		inc rsi
		jmp .loop
	
	.desempate:
		cmp dl,0 ;solo dl es 0
		je .pierde_a;a pierde porque es 0
		cmp cl,0 ;solo cl es 0
		je .pierde_b
		cmp dl,cl ;ninguna de las dos es cero, cual pesa mas?
		jg .pierde_b

		.pierde_a: ;a < b
			add rax,1
			jmp .fin

		.pierde_b:
			sub rax,1

	.fin:
	pop rbp
	ret

; char* strClone(char* a)
;a = [rdi]
strClone:
	push rbp
	mov rbp,rsp
	push r12 ;preservo el valor de r12 porque es no volátil
	sub rsp,8 ;resto 8 para alinear el stack

	mov r12,rdi ;guardo el puntero en r12 para que se preserve luego de llamar a strLen y malloc
	call strLen
	mov rdi,rax ;almaceno en rdi el tamaño del string 
	inc rdi ;incremento en 1 el tamaño del string para que haya espacio para el caracter \0
	call malloc ;llamo a malloc y paso por rdi la cant de memoria que necesito
	mov rdx, rax ;copio la direccion del inicio del espacio de memoria para no trabajar con rax 
	
	.loop:
		mov sil,[r12] ;almaceno char en la parte baja de rsi
		cmp sil,0 ; char == \0 ?
		je .fin
		mov [rdx],sil ;guardo char en la "nueva" memoria
		inc rdx ;avanzo al siguiente espacio de memoria a cubrir
		inc r12 ;avanzo al siguiente char a copiar
		jmp .loop

	.fin:
	mov [rdx],sil ;guardo \0 en el ultimo espacio de memoria

	add rsp,8 ;restauro el stack
	pop r12
	pop rbp
	ret

; void strDelete(char* a)
;a = [rdi]
strDelete:
	push rbp
	mov rbp,rsp
	;free recibe un puntero al comienzo de la memoria solicitada con malloc y libera el bloque completo
	call free ;llamo a free pasandole rdi como puntero

	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
;a = [rdi], pFile = [rsi]
strPrint:
	push rbp
	mov rbp,rsp
	
	;fprintf necesita recibir el FILE* por rdi, un formato de impresion por rsi y un puntero al string por rdx 
	mov rdx,rdi
	mov rsi, formato
	mov rdi,rsi
	call fprintf

	pop rbp
	ret

; uint32_t strLen(char* a)
;a = [rdi]
strLen:
	push rbp
	mov rbp,rsp
	xor rax,rax ;contador

	.loop:
		mov dl, [rdi]
		cmp dl,0 ; char = \0 ?
		je .fin
		inc rax ;como char != \0 incrementa el contador
		inc rdi ;avanzo al siguiente char
		jmp .loop 

	.fin:
	pop rbp
	ret


