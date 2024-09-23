section .data 
    %define OT_SIZE 16
    %define OT_TABLESIZE_OFFSET 0
    %define OT_NODOOTT_OFFSET 8
    
    %define DISPLAY_LIST_PRIMITIVA_OFFSET 0
    %define DISPLAY_LIST_X_OFFSET 8
    %define DISPLAY_LIST_Y_OFFSET 9
    %define DISPLAY_LIST_Z_OFFSET 10
    %define DISPLAY_LIST_SIGUIENTE_OFFSET 16

section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free


;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size);
;dil viene table size
inicializar_OT_asm:
    push rbp
    mov rbp,rsp

    xor rax, rax     ;limpio rax y lo establezco como el tamaño de la estructura para usarlo con el mul
    mov al, OT_SIZE  
    mul dil         ; OT_size * table_size
    mov dil, al

    call malloc 
    
    mov [rax],r12b 

    pop rbp
ret
; void* calcular_z(nodo_display_list_t* display_list, uint8_t z_size) ;
calcular_z_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    mov rbx, rdi                        ;copiamos el puntero para no perderlo
    mov r12b, sil                        ;copiamos el z_size
    mov rdi,[rbx + DISPLAY_LIST_X_OFFSET] ;pasamos x a la funcion
    mov rsi,[rbx + DISPLAY_LIST_Y_OFFSET] ;pasamos y a la funcion 
    mov cl,r12b                         ;pasamos z_size a la funcion
    call [rbx + DISPLAY_LIST_PRIMITIVA_OFFSET] ;llamamos a la funcion primitiva
    mov [rbx + DISPLAY_LIST_Z_OFFSET], rax
    
    pop r12
    pop rbx
    pop rbp
ret
; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
ordenar_display_list_asm:
 push rbp
    mov rbp,rsp
    
    
    pop rbp
ret

