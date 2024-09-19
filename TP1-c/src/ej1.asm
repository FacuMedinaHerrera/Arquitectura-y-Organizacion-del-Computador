section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
luminosidad_mask: dd 0.0, 0.71520, 0.07220, 0.21260 
alfa: dd 255, 0, 0, 0
transparency_mask: dd 0, 1, 1, 1



section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej1
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Convierte una imagen dada (`src`) a escala de grises y la escribe en el
; canvas proporcionado (`dst`).
;
; Para convertir un píxel a escala de grises alcanza con realizar el siguiente
; cálculo:
; ```
; luminosidad = 0.2126 * rojo + 0.7152 * verde + 0.0722 * azul 
; ```
;
; Como los píxeles de las imágenes son RGB entonces el píxel destino será
; ```
; rojo  = luminosidad
; verde = luminosidad
; azul  = luminosidad
; alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej1
ej1:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = rgba_t*  dst
	; r/m64 = rgba_t*  src
	; r/m32 = uint32_t width
	; r/m32 = uint32_t height
	;rdi[dst] rsi[src] edx[width] ecx[height]
	; push rbp
	; mov rbp,rsp

	; imul ecx,edx ; no estoy segura de si debería preservar ecx... 
	; sar ecx, 1 ; En fin, calculo la cant de pixeles de la imagen y lo divido por la cant que entran en un xmm
	; ;consultar los decimales
	; movdqu xmm1, [luminosidad_mask] ;me guardo la mascara de luminosidad en xmm1 
	; movdqu xmm2, [alfa] ; 255 | 0 | 0 | 0  -> no se si hay una forma mas eficiente de hacer esto.. no se me ocurrió otra
	; movdqu xmm3, [transparency_mask] 
	; .ciclo:
	; 	pmovzxbw xmm0, [rsi] ; me traigo los primeros 2 pixeles
	; 	pmovzxbw xmm4, [rsi]
	; 	; extiendo cada canal (1B) a word (2B)

	; 	pmullw xmm0, xmm1 ; A*0 | G*0,7152 | B*0,0722 | R*0,2126 ;pixel bajo
	; 	pmulhw xmm4, xmm1 ; A*0 | G*0,7152 | B*0,0722 | R*0,2126 ;pixel alto 

	; 	phaddw xmm0,xmm0 ; ... | ... | 0+G2 | B2+R2 | ... | ... | 0+G2 | B2+R2
	; 	phaddw xmm0,xmm0 ; ... | ... | ...| G2+B2+R2 | ... | ... | ...| G2+B2+R2
	; 	phaddw xmm4,xmm4
	; 	phaddw xmm4,xmm4

	; 	pshuflw xmm0,xmm0,0x00 ; G2+B2+R2  | G2+B2+R2 | G2+B2+R2 | G2+B2+R2 En el primer pixel (0x00 = 0000 0000)
	; 	pshufhw xmm4,xmm4, 0x00 ; G2+B2+R2 | G2+B2+R2 | G2+B2+R2 | G2+B2+R2 En el segundo pixel
	; 	pshufhw xmm0, xmm4, 0xE4 ; restauro los 2 pixeles en xmm0 (1110 0100 = 0xE4)
		
	; 	pand xmm0, xmm3 ;mascara de transparencia
	; 	paddw xmm0, xmm2 ; 255 | G2+B2+R2 | G2+B2+R2 | G2+B2+R2

	; 	packsswb xmm0,xmm0 ;empaqueto nuevamente mis pixeles en formato 4B cada uno.
	; 	movq [rdi], xmm0 ;almaceno los pixeles modificados

	; 	add rdi,8 ; avanzo al proximo conjunto de pixeles
	; loop .ciclo
	; pop rbp
	; ret

	;resuelto sin SIMD:
			; push rbp
			; mov rbp,rsp
			; sub rsp,8
			; push r12
			; xor r12,r12
			; pxor xmm0,xmm0
		
			; mov r8d,ecx
			; mov r9d,edx 
			; .filas:
			; 	dec r8d
			; 	cmp r8d,0
			; 	je .fin
			; 	mov r9d,edx
			; 	.columnas:
			; 		cmp r9d,0
			; 		je .filas
			; 		pmovzxbd xmm0,[rsi]
			; 		movd [rsp-8],xmm0
			; 		CVTPI2PD xmm0,[rsp-8] ;convierto dword integer to dword fp double precision
			; 		movdqu xmm1,[luminosidad_mask]
			; 		mulpd xmm0,xmm1
			; 		movd [rsp-8],xmm0
			; 		CVTSD2SI r12,[rsp-8]
			; 		movd [rsp-8], r12
			; 		movd xmm0,[rsp-8]
			; 		phaddd xmm0, xmm0
			; 		phaddd xmm0, xmm0 ;[r+g+b+a][...][...][r+g+b+a]
			; 		movdqu xmm3, [transparency_mask]
			; 		pand xmm0,xmm3 ;[0000][...][...][r+g+b+a]
			; 		movdqu xmm4,[alfa]
			; 		paddd xmm0, xmm4
			; 		movdqu [rdi], xmm0	
			; 		add rsi, 4 ;proximo pixel
			; 		dec r9d
			; 		jmp .columnas
				
			; .fin:
			; pop r12
			; pop rbp
			; ret

