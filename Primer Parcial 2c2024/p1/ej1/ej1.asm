extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
%define TAM_ITEM_T  28			;2 de padding al final de la estructura para que queda alineado a 4 bytes
%define NOMBRE_OFFSET 0
%define FUERZA_OFFSET 20		;hay 2 de padding para que este alineado a 4 bytes
%define DURABILIDAD_OFFSET 24


section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = item_t**     inventario	[rdi]
	; r/m64 = uint16_t*    indice		[rsi]
	; r/m16 = uint16_t     tamanio		[rdx]
	; r/m64 = comparador_t comparador	[rcx]
	;
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	
;dejo armado el prologo alineado.
	mov rbx,rdi				;inventario
	mov r12,rsi				;indice
	mov r13,rdx				;tamanio
	mov r14,rcx				;comparador
;me copio mis datos a registros no volatiles para no perderlos al hacer el llamado al comparador
	
	
	.ciclo:
		mov rax, qword 1	;asumo que es verdadero en un principio, si es falso cambio valor y salgo
		cmp r13w,word 1		;comparo en tamanio word porque no se si el resto tiene basura y comparo con 1 ya que si no, indexo erroneamente
		je .fin
		xor rdi,rdi
		xor rsi,rsi			;limpio los registros para no usar datos basura
		xor rdx,rdx
		xor rcx,rcx
		mov dx,[r12]		;indice[i]
		mov cx,[r12+2]		;indice[i+1] Es +2 ya que cada entero es de 2 bytes 
		mov rdi,[rbx+rdx*8]	;pongo en rdi inventario[indice[i]]. Se multiplica x8 porque cada posicion tiene tamanio de puntero.
		mov rsi,[rbx+rcx*8]	;pongo en rsi inventario[indice[i+1]]
		call r14			;llamo a comparador(inventario[indice[i]],inventario[indice[i+1]])
		cmp al,byte 0		;es false?
		je .false
		add r12,2
		dec r13w
		jmp .ciclo


		.false:
				mov rax,qword 0
				jmp .fin
	
	.fin:
	
	pop r14
	pop r13	
	pop r12
	pop rbx	
	pop rbp
	ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = item_t**  inventario	[rdi]
	; r/m64 = uint16_t* indice		[rsi]
	; r/m16 = uint16_t  tamanio		[rdx]
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	push r13
	push r14
;pila alineada
	mov rbx,rdi
	mov r12,rsi
	mov r13,rdx

	shl r13w,3 		;multiplico por 8 el tamanio para pedir memoria correctamente
	xor rdi,rdi
	mov di,r13w
	shr r13w,3		;restauro el tamanio para iterar correctamente
	call malloc		;memoria reservada para resultado
	mov r14,rax	;	guardo el puntero de resultado

	.loop:
		cmp r13w,word 0
		je .end
		xor rdi,rdi				;limpio registros
		xor rsi,rsi
		mov di, [r12]			;indice[i]	
		mov rsi,[rbx+rdi*8]		;inventario[indice[i]]
		mov [r14],rsi			;resultado[i]=riventario[indice[i]]
		
		add r14,8				;8 por el tamanio de punteros a items
		add r12,2
		dec r13w
		jmp .loop

	.end:
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
