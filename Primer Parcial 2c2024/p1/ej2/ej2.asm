section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el filtro
SUBSTRACT_MASK:times 4 dd 128
alfa_mask:dd 0,0,0,255
cero_mask: dd 255,255,255,0
div_mask: times 4 dd 32.0
saturation_mask_min:times 4 dd 0
saturation_mask_max: times 4 dd 255
ALIGN 16

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2a
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 2B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2b
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 2C (opcional) como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2c
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:    La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:    La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:  El ancho en píxeles de `dst`, `src` y `mask`.
;   - height: El alto en píxeles de `dst`, `src` y `mask`.
;   - amount: El nivel de intensidad a aplicar.
global ej2a
ej2a:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = rgba_t*  dst		[rdi]
	; r/m64 = rgba_t*  src		[rsi]
	; r/m32 = uint32_t width	[rdx]
	; r/m32 = uint32_t height	[rcx]
	; r/m8  = uint8_t  amount	[r8]
	push rbp
	mov rbp, rsp
	
	imul rcx,rdx
	movd xmm2,r8d
	pmovzxbd xmm2,xmm2 					;convierto de byte a double
	phaddd xmm2,xmm2
	phaddd xmm2,xmm2					;pongo en cada canal la saturacion
	movdqu xmm1,[SUBSTRACT_MASK]
	movdqu xmm3,[cero_mask]
	movdqu xmm4,[alfa_mask]
	movdqu xmm5,[div_mask]
	movdqu xmm6,[saturation_mask_min]
	movdqu xmm7,[saturation_mask_max]

	.ciclo:
		pmovzxbd xmm0,[rsi]				;agarro un pixel y lo convierto en 4 canales de 32 bits cada uno 

		psubd xmm0,xmm1 				;resto 128 a cada color

		pmulld xmm0,xmm2				;multiplico por el contraste

		cvtdq2ps xmm0,xmm0
		divps xmm0,xmm5					;divido por 32
		cvtps2dq xmm0,xmm0

		paddd xmm0,xmm1					;sumo 128 a cada valor

		pmaxsd xmm0,xmm6				;saturo
		pminsd xmm0,xmm7

		pand xmm0,xmm3					;pongo en 0 el alfa
		por xmm0,xmm4					;pongo en 255 el alfa

		packusdw xmm0,xmm0				;convierto los canales de doubles a word a bytes como era originalmente
		packuswb xmm0,xmm0

		movd [rdi],xmm0					;son 4 canales de 8 bits, muevo entonces una dword a rdi
	
		add rdi,4
		add rsi,4
	loop .ciclo

	pop rbp
	ret

; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:    La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:    La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:  El ancho en píxeles de `dst`, `src` y `mask`.
;   - height: El alto en píxeles de `dst`, `src` y `mask`.
;   - amount: El nivel de intensidad a aplicar.
;   - mask:   Una máscara que regula por cada píxel si el filtro debe o no ser
;             aplicado. Los valores de esta máscara son siempre 0 o 255.
global ej2b
ej2b:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = rgba_t*  dst		[rdi]
	; r/m64 = rgba_t*  src		[rsi]
	; r/m32 = uint32_t width	[rdx]
	; r/m32 = uint32_t height	[rcx]
	; r/m8  = uint8_t  amount	[r8]
	; r/m64 = uint8_t* mask		[r9]
	push rbp
	mov rbp, rsp
	
	imul rcx,rdx
	movd xmm2,r8d
	pmovzxbd xmm2,xmm2 					;convierto de byte a double
	phaddd xmm2,xmm2
	phaddd xmm2,xmm2					;pongo en cada canal la saturacion
	movdqu xmm1,[SUBSTRACT_MASK]
	movdqu xmm3,[cero_mask]
	movdqu xmm4,[alfa_mask]
	movdqu xmm5,[div_mask]
	movdqu xmm6,[saturation_mask_min]
	movdqu xmm7,[saturation_mask_max]
	.cycle:
		mov r8b,byte [r9]
		cmp r8b,byte 255
		jne .notFilter
		pmovzxbd xmm0,[rsi]				;agarro un pixel y lo convierto en 4 canales de 32 bits cada uno

		psubd xmm0,xmm1 				;resto 128 a cada color

		pmulld xmm0,xmm2				;multiplico por el contraste

		cvtdq2ps xmm0,xmm0
		divps xmm0,xmm5					;divido por 32
		cvtps2dq xmm0,xmm0

		paddd xmm0,xmm1					;sumo 128 a cada valor

		pmaxsd xmm0,xmm6				;saturo
		pminsd xmm0,xmm7

		pand xmm0,xmm3					;pongo en 0 el alfa
		por xmm0,xmm4					;pongo en 255 el alfa

		packusdw xmm0,xmm0				;convierto los canales de doubles a word a bytes como era originalmente
		packuswb xmm0,xmm0

		movd [rdi],xmm0					;son 4 canales de 8 bits, muevo entonces una dword a rdi
		add rdi,4
		add rsi,4
		inc r9
	loop .cycle	
		.notFilter:
				mov r8d,dword[rsi]			;muevo pixel sin filtrar
				mov [rdi],r8d
				add rdi,4
				add rsi,4
				inc r9	
	loop .cycle

	pop rbp
	ret


; [IMPLEMENTACIÓN OPCIONAL]
; El enunciado sólo solicita "la idea" de este ejercicio.
;
; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:     La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:     La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:   El ancho en píxeles de `dst`, `src` y `mask`.
;   - height:  El alto en píxeles de `dst`, `src` y `mask`.
;   - control: Una imagen que que regula el nivel de intensidad del filtro en
;              cada píxel. Es en escala de grises a 8 bits por canal.
global ej2c
ej2c:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = rgba_t*  dst
	; r/m64 = rgba_t*  src
	; r/m32 = uint32_t width
	; r/m32 = uint32_t height
	; r/m64 = uint8_t* control
	
	
	
	
	ret
