
section .data

CONSTANTE_ROJO dd 0.299
CONSTANTE_VERDE dd 0.587
CONSTANTE_AZUL dd 0.114

;########### SECCION DE TEXTO (PROGRAMA)
section .text

global miraQueCoincidencia
miraQueCoincidencia:    ; void miraQueCoincidencia_c( uint8_t *A[rdi], uint8_t *B[rsi], uint32_t N[rdx], 
                        ;    uint8_t *laCoincidencia[rcx] ){
    ; Prólogo
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    push rdi    ; Únicamente para realinear la pila a 16bytes
    ; Fin prólogo

    mov r15, rcx    ; Guardo el puntero a *laCoincidencia para usar loop
    mov r14, rdx    ; Guardo N

    mov r8d, [CONSTANTE_ROJO]
    mov r9d, [CONSTANTE_VERDE]
    mov r10d, [CONSTANTE_AZUL]
    xor r11, r11

    ; Hago una máscara con las constantes en su correspondiente posición.
    ; La disposición de cada pixel es       bit0 || Azul | Verde | Rojo | Alfa || bit127
    pinsrd xmm15, r10d, 0
    pinsrd xmm15, r9d, 1
    pinsrd xmm15, r8d, 2
    pinsrd xmm15, r11d, 3       ; En este insert se ponen 0s en el último Dword para multiplicar el Alfa, así no afecta el resultado de la operación

    ; -----------------------------------------------------------------------------------

    ; Si bien los registros xmm permiten traer de a 4 pixeles, solo 1 podrá ser procesado a la vez, ya que hay que hacer operaciones de punto flotante (32bits)
    ; Por tanto, tengo que convertir cada componente del pixel a float, ocupando todo el espacio del xmm
    
    ; Entonces tengo que hacer N*N iteraciones
    mov rax, rdx
    mul r14         ; Hago N*N
    mov rcx, rax

    ; -----------------------------------------------------------------------------------
    .ciclo:
        ; No utilizo instrucciones SIMD para traer los pixeles a los registros porque se va a procesar de 1 pixel.
        ; Aun así se podría haber utilizado movdqu pero tendría que haber contemplado los casos borde, que son los tres últimos pixeles
        ; de las imágenes A y B con algún condicional, sino podría haber un problema de memoria por intentar acceder a una posición que no fue reservada
        ; para A y B
        mov r10, [rdi]  ; Traigo un pixel de A
        mov r11, [rsi]  ; Traigo un pixel de B

        movq xmm0, r10  ; Llevo el pixel A a un xmm
        movq xmm1, r11  ; Llevo el pixel B a un xmm

        ; Desempaqueto ambos pixeles para que cada componente tenga 32bits
        pmovzxbd xmm0, xmm0
        pmovzxbd xmm1, xmm1

        pcmpeqd xmm0, xmm1      ; Comparo las componentes de los pixeles


        ; Si las componentes son iguales, xmm0 = bit0 | 1 | 1 | 1 | 0/1 | bit127
        ; Los alfa pueden o no ser iguales, hay que tener en cuenta eso para ignorarlo

        ; Desfaso cada posición de 31bits para quedarme con 0 o 1 en cada posición 
        psrld xmm0, 31

        ; Ahora hago dos sumas horizontales para obtener un valor en el primer Dword de xmm0. Teniendo en cuenta que hay que ignorar el alfa,
        ; si los pixeles son iguales entonces el valor podrá ser 3 o 4 (este último en caso que coincidan los alfa).
        ; Por tanto, el valor debe ser >= 3
        pxor xmm14, xmm14   ; Inicializo xmm14 en 0 para usarlo como segundo parámetro de phadd
        phaddd xmm0, xmm14
        phaddd xmm0, xmm14

        ; Ahora extraigo el valor a un registro de próposito general
        pextrd r13d, xmm0, 0

        ; Hago la comparación para saber si son iguales
        mov r12, 3
        cmp r13, r12
        jl .else
            ; En esta rama se cumple que valor >= 3
            ; Siendo el caso en que los pixeles son iguales

            ; Ahora opero con el pixel B (aunque también podría haber sido el A)
            ; Convierto los enteros a floats
            cvtdq2ps xmm1, xmm1

            ; Multiplico por las constantes correspondientes a cada componente
            mulps xmm1, xmm15

            

            ; Ahora hago dos sumas horizontales para obtener el valor final, que estará en el primer Dword de xmm1
            haddps xmm1, xmm14
            haddps xmm1, xmm14

            ; Convierto el resultado a int32
            ; Como nota, cabe decir que se usa la versión truncada del convert para que coincida con los test, pero la versión con redondeo parecía dar resultados más precisos
            ; Aun así, tampoco se especifica en el enunciado de qué manera se tiene que redondear
            cvttps2dq xmm1, xmm1

            ; Extraigo el valor (que está en la primer posición del xmm) y lo pongo en un registro de propósito general
            pextrd r13d, xmm1, 0

            ; Ahora lo mando a la memoria
            mov [r15], r13b
            
            jmp .fin_if
        .else:
            ; Si los pixeles son distintos, entonces escribo 255 en la posición de laCoincidencia
            mov [r15], BYTE 255
        .fin_if: 

        add r15, 1      ; Incremento el puntero a laCoincidencia en 1 para que vaya al siguiente pixel

        ; Incremento los punteros de ambas imágenes para acceder a su pixel siguiente (4bytes mide un pixel)
        add rdi, 4
        add rsi, 4     

        dec rcx
    jnz .ciclo  ; No se puede usar loop porque el short jump es muy grande


    ; Epílogo
    pop rdi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

