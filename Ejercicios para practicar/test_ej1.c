#include "ej1.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(){
    printf("= Tests de Ej1:\n");
    printf("==============================\n");
    char* string=malloc(sizeof(char)*10); //max word's length is 9.
    char* ans;
    char* ans_asm;
    string="BURNING\0";
    ans=cesarCodSimple(string,3);
    ans_asm=codificationCesar(string,3);
    printf("(%s,3)\n--->Expected: 'EXUQLQJ' Actual:'%s')\n",string,ans);
    printf("Now using asm\n");
    printf("(%s,3)\n--->Expected: 'EXUQLQJ' Actual:'%s')\n",string,ans_asm);
    string="PLANTING\0";
    free(ans);
    free(ans_asm);
    ans=cesarCodSimple(string,32);
    ans_asm=codificationCesar(string,32);
    printf("(%s,32)\n--->Expected:'VRGTZOTM' Actual:'%s')\n",string,ans_asm);

    exit(0);
}