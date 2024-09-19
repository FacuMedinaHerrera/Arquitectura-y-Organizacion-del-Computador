#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
    uint32_t i = 0;
    uint32_t j = 0;
   
    if(string ==NULL){
        return j;
    }
    while (string[i] != '\0'){
        i++;
    }

    return i; 
}

uint32_t contar_espacios(char* string) {
    uint32_t i = 0;
    uint32_t j = 0;
    if(string ==NULL){
        return j;
    }
    while (string[i] != '\0'){

        if (string[i] == ' '){
            j++;
        }
        
        i++;
    }

    return j;
}

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
}
*/