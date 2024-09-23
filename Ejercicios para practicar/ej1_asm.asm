extern ord
extern chr
extern malloc
extern strlen
; Data section
section .data

; text section (code)
section .text

; exported functions:

global codificationCesar

; functions definitions:


; codeCesar(char* frase,uint32_t x); rdi[char*],rsi[uint8_t]
codificationCesar:
    push rbp
    mov rbp,rsp
    push rbx
    push r12
    push r13
    push r14
    ;pushing 2 non volatile registers to save frase and x
    mov rbx, rdi
    mov r12b,sil
    
    call strlen
    ;I recieve frase's length via RAX register
    mov edi,eax
    inc edi
    call malloc
    ;now I have a pointer to reserved memory for my string
    mov r13,rax ;copy the pointer so I don't lose it
    mov r14,rax
    .loop:
        cmp [rbx],byte 0
        je .fin
        mov dil,byte [rbx]
        call ord
        add al, r12b
        mov dil, al
        call chr
        mov [r13],al
        inc rbx
        inc r13
        jmp .loop
    .fin:
    mov [r13],byte 0 ;end of string
    mov rax, r14 ;return register
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret