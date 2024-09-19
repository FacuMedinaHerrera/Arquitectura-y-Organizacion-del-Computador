

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	28
LONGITUD_OFFSET	EQU	24

PACKED_NODO_LENGTH	EQU	21
PACKED_LONGITUD_OFFSET	EQU	17

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi] (es un puntero)
cantidad_total_de_elementos:
	push rbp
	mov rbp, rsp
	xor rax,rax ;contador
	;if puntero no nulo avanzar y sumar al contador las longitudes
	.loop:
		mov rdi, [rdi]
		cmp rdi,0
		je .fin
		add rax, [rdi+LONGITUD_OFFSET] ;sumamos longitud
		jmp .loop
	.fin:
	pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
push rbp
mov rbp, rsp
xor rax,rax ;contador
	;if puntero no nulo avanzar y sumar al contador las longitudes
	.loopPacked:
		mov rdi, [rdi]
		cmp rdi,0
		je .finPacked
		add eax, [rdi+PACKED_LONGITUD_OFFSET] ;sumamos longitud
		jmp .loopPacked
.finPacked:
pop rbp
ret

