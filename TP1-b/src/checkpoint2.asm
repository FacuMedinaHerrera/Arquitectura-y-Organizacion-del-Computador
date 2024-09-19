extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4:
	;prologo
	push rbp
	mov rbp,rsp
	
	sub edi, esi
	add edi, edx
	sub edi, ecx
	mov eax, edi


	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp
	push rbx
	push r12

	mov ebx, edx
	mov r12d, ecx
	call restar_c
	mov edi, eax
	mov esi, ebx
	call sumar_c
	mov edi, eax
	mov esi, r12d
	call restar_c
	
	;epilogo
	pop r12
	pop rbx
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:

	sub edi, esi
	add edi, edx
	sub edi, ecx
	mov eax, edi
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[rbp+0x10], x8[rbp+0x18]
alternate_sum_8:
	;prologo
	push rbp
	mov rbp, rsp

	sub edi, esi
	add edi, edx
	sub edi, ecx
	add edi, r8d
	sub edi, r9d
	add edi,[rbp+0x10]
	sub edi, [rbp+0x18]
	mov eax, edi

	;epilogo
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]
product_2_f:
	push rbp
	mov rbp, rsp

	CVTSI2SD xmm1,rsi ;Convert Doubleword Integer to Scalar Single Precision Floating-Point Value
	CVTSS2SD xmm0,xmm0
	MULSD xmm0,xmm1 
	CVTTSD2SI rax,xmm0
	mov [rdi],eax
	
	pop rbp
	ret

;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[rbp+0x10], f6[xmm5], x7[rbp+0x18], f7[xmm6], x8[rbp+0x20], f8[xmm7],
;	, x9[rbp+0x28], f9[rbp+0x30]
product_9_f:
	push rbp
    mov rbp, rsp

    ;convertimos los flotantes de cada registro xmm en doubles
    CVTSS2SD xmm0, xmm0 ;Convert Scalar Single Precision Floating-Point Value to Scalar Double PrecisionFloating-Point Value
    CVTSS2SD xmm1, xmm1
    CVTSS2SD xmm2, xmm2
    CVTSS2SD xmm3, xmm3
    CVTSS2SD xmm4, xmm4
    CVTSS2SD xmm5, xmm5
    CVTSS2SD xmm6, xmm6
    CVTSS2SD xmm7, xmm7
    CVTSS2SD xmm8, [rbp+0x30]


    ;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmm0 * xmm2 , ...
    MULSD xmm0,xmm1 ;Multiply Scalar Double Precision Floating-Point Value
    MULSD xmm0,xmm2
    MULSD xmm0,xmm3
    MULSD xmm0,xmm4
    MULSD xmm0,xmm5
    MULSD xmm0,xmm6
    MULSD xmm0,xmm7
    MULSD xmm0,xmm8

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	CVTSI2SD xmm1,rsi ;Convert Doubleword Integer to Scalar Double Precision Floating-Point Value
	CVTSI2SD xmm2,rdx
	CVTSI2SD xmm3,rcx
	CVTSI2SD xmm4,r8
	CVTSI2SD xmm5,r9
	CVTSI2SD xmm6,[rbp+0x10]
	CVTSI2SD xmm7,[rbp+0x18]
	CVTSI2SD xmm8,[rbp+0x20]
	CVTSI2SD xmm9,[rbp+0x28]

	MULSD xmm0,xmm1 ;Multiply Scalar Double Precision Floating-Point Value
    MULSD xmm0,xmm2
    MULSD xmm0,xmm3
    MULSD xmm0,xmm4
    MULSD xmm0,xmm5
    MULSD xmm0,xmm6
    MULSD xmm0,xmm7
    MULSD xmm0,xmm8
    MULSD xmm0,xmm9
	;28020030711982952716680218100848213694741479424.00
	movq [rdi],xmm0
	; epilogo
	pop rbp
	ret