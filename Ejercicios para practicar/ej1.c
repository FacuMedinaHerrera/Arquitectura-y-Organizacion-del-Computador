#include "ej1.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

uint8_t ord(char letter){
    return letter-'A';
}
char chr(uint8_t num){
    num = num % 26;
    return 'A'+num;
}
char* cesarCodSimple(char* frase,uint32_t x ){
    char* ans=malloc(strlen(frase)+1);
    for(uint8_t i=0;frase[i]!='\0';i++){
        ans[i]=chr(ord(frase[i])+x);
    }
    return ans;
}

