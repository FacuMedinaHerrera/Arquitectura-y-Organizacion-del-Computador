section .data
compare_mask: dq 127,127
trash_mask: dd 1,1,1,0
substract_mask: times 2 dd 128
red_mask: dd 1.0,1.0,1.0,1.370705
green_mask: dd 1.0,1.0,0.698001,0.337633
blue_mask: dd 1.0,1.0,1.0,1.732446
a_mask: dd 0.0,0.0,0.0,255.0

p_error_mask: times 2 db 127,255,0,255 



;########### SECCION DE TEXTO (PROGRAMA)
section .text
global YUYV_to_RGBA



;void YUYV_to_RGBA( int8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
                    ;dst [rdi]   ;src[rsi]    ;w_src[rdx]     ;h_src[rcx]
YUYV_to_RGBA:
    push rbp
    mov rbp, rsp
    xor r8,r8
    imul edx,ecx ;variable de iteracion

    .ciclo:
        cmp edx,0
        je .fin

        ;mov r8d,dword [rsi]  ;y1,u,y2,v -> y1uv y2uv
        pmovzxbd xmm0, [rsi]   ;cada canal a 32b
                            ; Y1 | U | Y2 | V ?
                            ; 11 | 10 | 01 | 00 
        pshufd xmm1,xmm0, 0xC8 ; 1100 1000
        pshufd xmm2,xmm0, 0x48 ; 0100 1000
        movdqu xmm3,[trash_mask] ;mascara para anular el ultimo dato 
        pmulld xmm1,xmm3
        pmulld xmm2,xmm3         ;limpiamos basura
                                 ;[0,y,u,v] ->[u,v] .. u == 127? --> u == v ?
        pmovzxdq xmm5,xmm1
        movdqu xmm6,[compare_mask] ;me fijo si viene con error
        pcmpeqq xmm5,xmm6 ;11111 111111
        psllq xmm5,63
        psrlq xmm5,63     ;si son iguales -> 0001 | 0001 
        pextrq rbx,xmm5,0
        pextrq r9,xmm5,1
        cmp rbx,r9
        je .pixelError    ;son iguales, hay error

        pxor xmm4,xmm4              ;limpiamos xmm4 para que no interfiera con la resta
        movq xmm4,[substract_mask]
        psubd xmm1,xmm4
        psubd xmm2,xmm4
            ;conversion pixel 1
                movdqu xmm0,xmm1 ;copio pixel y1

                pshufd xmm1, xmm0,0x08 ; Lo necesario para las operaciones del canal R
                pshufd xmm3, xmm0,0x09 ; Lo necesario para las operaciones del canal B
                pshufd xmm0,xmm0,0xC2  ; 1100 0010  
                CVTDQ2PS xmm1,xmm1     ; convertimos a float para operar 
                CVTDQ2PS xmm3,xmm3
                
                movdqu xmm4,[red_mask]
                mulps xmm1,xmm4 ; V * 1.370705
                movdqu xmm4,[blue_mask] 
                mulps xmm3,xmm4 ;U * 1.732446
                movdqu xmm4,[green_mask]
                mulps xmm0,xmm4 
                ;sumared:
                haddps xmm1,xmm1  ;Y + V * 1.370705  [00,00,Y,V] -> [00+00,y+v,00+00,y+v]
                ;sumablue
                haddps xmm3,xmm3  ;Y + U * 1.732446 [00,00,Y,U] -> [00+00,y+u,00+00,y+u]
                ;sumagreen
                haddps xmm0,xmm0 ;  Y-0 | 0.698001 * V - 0.337633 * U [y,0,v,u]->[y,v+u,y,v+u]
                hsubps xmm0,xmm0 ;  Y - 0.698001 * V - 0.337633 * U [y,v+u,y,v+u]->[y-v-u,y-v-u,y-v-u,y-v-u]
                                ;  R | G | B | A 
                                ; 11 | 10 | 01 | 00        
                insertps xmm0,xmm1,0x30   ;0011 0000 ; R | G | G | G
                insertps xmm0,xmm3,0x11  ;00010001 ; R | G | B | 0
                movdqu xmm1,[a_mask]
                addps xmm0,xmm1             ;R | G | B | A
                
                cvtps2dq xmm0, xmm0
                PACKUSDW xmm0,xmm0          
                PACKUSWB xmm0,xmm0 
                
                movd ebx,xmm0
                mov dword [rdi],ebx
                add rdi,4
    
            ;conversion pixel 2   
                movdqu xmm0,xmm2 ;copio pixel y2

                pshufd xmm1, xmm0,0x08 ; Lo necesario para las operaciones del canal R
                pshufd xmm3, xmm0,0x09 ; Lo necesario para las operaciones del canal B
                pshufd xmm0,xmm0,0xC2  ; 1100 0010  
                CVTDQ2PS xmm1,xmm1     ; convertimos a float para operar 
                CVTDQ2PS xmm3,xmm3
                
                movdqu xmm4,[red_mask]
                mulps xmm1,xmm4 ; V * 1.370705
                movdqu xmm4,[blue_mask] 
                mulps xmm3,xmm4 ;U * 1.732446
                movdqu xmm4,[green_mask]
                mulps xmm0,xmm4 
                ;sumared:
                haddps xmm1,xmm1  ;Y + V * 1.370705  [00,00,Y,V] -> [00+00,y+v,00+00,y+v]
                ;sumablue
                haddps xmm3,xmm3  ;Y + U * 1.732446 [00,00,Y,U] -> [00+00,y+u,00+00,y+u]
                ;sumagreen
                haddps xmm0,xmm0 ;  Y-0 | 0.698001 * V - 0.337633 * U [y,0,v,u]->[y,v+u,y,v+u]
                hsubps xmm0,xmm0 ;  Y - 0.698001 * V - 0.337633 * U [y,v+u,y,v+u]->[y-v-u,y-v-u,y-v-u,y-v-u]
                                ;  R | G | B | A 
                                ; 11 | 10 | 01 | 00        
                insertps xmm0,xmm1,0x30 ;00110000 ; R | G | G | G
                insertps xmm0,xmm3,0x11 ;00010001 ; R | G | B | 0
                movdqu xmm1,[a_mask]        
                addps xmm0,xmm1             ;R | G | B | A

                cvtps2dq xmm0, xmm0
                PACKUSDW xmm0,xmm0          
                PACKUSWB xmm0,xmm0 
                
                movd ebx,xmm0
                mov dword [rdi],ebx
                add rdi,4
            dec edx
            jmp .ciclo
            
        .pixelError:
            mov r9, qword [p_error_mask]
            mov [rdi],r9
            add rdi,8 
            add rsi,4
            dec edx
            jmp .ciclo
              
    .fin:
    pop rbp
    ret
