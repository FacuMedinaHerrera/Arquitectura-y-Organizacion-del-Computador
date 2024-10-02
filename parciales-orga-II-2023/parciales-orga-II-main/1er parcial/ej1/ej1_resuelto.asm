global templosClasicos
global cuantosTemplosClasicos

extern malloc

TAM_STRUCT_TEMPLO equ           24
OFFSET_LARGO equ                0
OFFSET_NOMBRE equ               8
OFFSET_CORTO equ                16



;########### SECCION DE TEXTO (PROGRAMA)
section .text

templosClasicos: ; templosClasicos(templo *temploArr[rdi], size_t temploArr_len[rsi]);
    ; Prólogo
    push rbp
    mov rbp, rsp    ; Stack alineado a 16bytes
    push rbx
    push r15
    push r14
    push r13
    push r12
    push rdi        ; Únicamente para realinear el stack
    ; Fin prólogo


    ; Guardo los parámetros en registros no volátiles para que malloc no los altere
    mov r15, rdi
    mov r14, rsi

    call cuantosTemplosClasicos     ; Llamo a la funcion para saber el tamaño del nuevo arreglo

    ; Ahora hago los cálculos para saber cuántos bytes tengo que reservar
    mov r8, TAM_STRUCT_TEMPLO
    mul r8          ; Hago cuantosTemplosClasicos * TAM_STRUCT_TEMPLO
    mov rdi, rax    ; Lo paso a rdi para llamar a malloc(cuantosTemplosClasicos * TAM_STRUCT_TEMPLO)
    call malloc

    mov r12, rax    ; Guardo el puntero al nuevo array creado en r12

    mov rcx, r14    ; Cargo en rcx la cantidad de iteraciones
    mov rdi, r15    ; Vuelvo a poner el puntero al arreglo original en rdi
    mov r15, r12    ; Uso r15 para ir agregando al arreglo nuevo

    .ciclo:
        ; Inicializo en 0 cada registro usado 
        xor r8, r8
        xor r9, r9
        xor r10, r10
        xor rax, rax

        ; Traigo las partes del struct
        mov r8b, [rdi + OFFSET_LARGO]       ; M
        mov r9, [rdi + OFFSET_NOMBRE]       ; char* nombre
        mov r10b, [rdi + OFFSET_CORTO]      ; N

        ; Hago W = 2*N+1
        mov al, r10b        ; Muevo N a al para hacer mul
        mov rbx, 2
        mul bl              ; Hago 2*N
        inc ax              ; Le sumo 1 al resultado

        ; Me fijo si W = M
        cmp r8w, ax         ; Tengo que comparar los 16bits por si hay "overflow" en la multiplicación de 8bits
        jne .fin_if
            ; Como el templo es clásico, lo agrego al arreglo
            mov [r15 + OFFSET_LARGO], r8b
            mov [r15 + OFFSET_NOMBRE], r9
            mov [r15 + OFFSET_CORTO], r10b
            ; Incremento el puntero del nuevo arreglo para que vaya a la próxima posición
            add r15, TAM_STRUCT_TEMPLO
        .fin_if:

        ; Incremento el puntero del arreglo original para que vaya a la próxima posición
        add rdi, TAM_STRUCT_TEMPLO
    loop .ciclo

    ; Devuelvo el puntero al inicio del nuevo arreglo
    mov rax, r12

    ; Epílogo
    pop rdi
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbx
    pop rbp
    ret
    

cuantosTemplosClasicos: ; cuantosTemplosClasicos_c(templo *temploArr[rdi], size_t temploArr_len[rsi]){
    ; Prólogo
    push rbp
    mov rbp, rsp    ; Stack alineado a 16bytes
    push r15
    push r14
    push r13
    push r12
    ; Fin prólogo

    xor r12, r12    ; Uso r12 como contador

    mov rcx, rsi    ; Guardo la cantidad de elementos del templo en rcx para usar loop

    .ciclo:
        ; Inicializo en 0 cada registro usado 
        ;xor r15, r15
        ;xor r14, r14

        ; Traigo las componentes M y N
        mov r15b, [rdi + OFFSET_LARGO]      ; M
        mov r14b, [rdi + OFFSET_CORTO]      ; N

        ; Hago W = 2*N+1
        mov al, r14b        ; Muevo N a al para hacer mul
        mov r8, 2
        mul r8b             ; Hago 2*N
        inc ax              ; Le sumo 1 al resultado

        ; Me fijo si W = M
        cmp r15w, ax        ; Tengo que comparar los 16bits por si hay "overflow" en la multiplicación de 8bits
        jne .fin_if         
            inc r12         ; Incremento en 1 la cantidad de templos clásicos
        .fin_if:

        add rdi, TAM_STRUCT_TEMPLO  ; Desfaso TAM_STRUCT_TEMPLO al puntero para que acceda a la siguiente posición
    loop .ciclo

    ; Devuelvo la cantidad de templos clásicos
    mov rax, r12 
    
    ; Epílogo
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbp
    ret

