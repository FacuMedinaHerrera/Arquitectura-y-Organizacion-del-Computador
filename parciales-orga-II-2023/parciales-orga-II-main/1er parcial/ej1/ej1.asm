extern malloc

%define TAM_STRUCT_TEMPLO 24
%define OFFSET_LARGO 0
%define OFFSET_CORTO 16
%define OFFSET_NOMBRE 8

section .data


section .text
;######### Aca empiezqa el codigo
;uint32_t cuantosTemplosClasicos(templo* temploArr,size_t temploArr_len)
;*templo[rdi],temploArr_len[rsi]
cuantosTemplosClasicos:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    xor rdx,rdx
    xor rcx,rcx
    xor rbx,rbx
    .ciclo:
        cmp rdi,qword 0
        je .fin
        mov dl,byte [rdi+OFFSET_CORTO]
        shl dx,1    ;multiplico por 2 el corto
        inc dx      ;Obtengo 2N+1
        mov cl,[rdi+OFFSET_LARGO]
        cmp dx,cx ;comparo 2N+1 = M
        je .esClasico
        jmp .guarda

        .esClasico:
            inc ebx
        
        .guarda:
            add rdi,TAM_STRUCT_TEMPLO
    jmp .ciclo
    .fin:
    mov eax,ebx
    pop r12
    pop rbx
    pop rbp
    ret