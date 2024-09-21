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
    mov r12d,esi
    
    call strlen
    ;I recieve frase's length via RAX register
    mov edi,eax
    inc edi
    call malloc
    ;now I have a pointer to reserved memory for my string
    mov r13,rax ;copy the pointer so I don't lose it

    .loop:
        cmp [rbx],dword 0
        je .fin
        mov rdi,[rbx]
        call ord
        add eax, r12d
        mov edi, eax
        call chr
        mov [r13],rax
        inc rbx
        inc r13
        jmp .loop
    .fin:
    mov [r13],dword 0 ;end of string
    mov rax, r13 ;return register
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret