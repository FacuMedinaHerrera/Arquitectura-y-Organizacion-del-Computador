#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {

    vector_t* vector_nuevo = malloc(sizeof(vector_t));

    vector_nuevo->capacity = 2;
    vector_nuevo->size = 0;

    vector_nuevo->array = malloc(2*sizeof(uint32_t));

    return vector_nuevo;
}

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
    if (vector->capacity == vector->size){
        vector->array = realloc(vector->array,2*(vector->capacity)*sizeof(uint32_t));
        vector->capacity = 2*vector->capacity;
        uint32_t index = vector->size;
        vector->array[index] = elemento;
        vector->size++;
    }else{
        uint32_t index = vector->size;
        vector->array[index] = elemento;
        vector->size++;
    }
}

int son_iguales(vector_t* v1, vector_t* v2) {
    int son_iguales = 1;
    uint64_t sizevector1 = 0;
    uint64_t sizevector2 = 0;
    uint32_t * vector1 = NULL;
    uint32_t * vector2 = NULL;
    
    sizevector1 = v1->size;
    sizevector2 = v2->size;

    vector1 = v1->array;
    vector2 = v2->array;


    if(sizevector1 == sizevector2){

        for(uint64_t i=0;i<sizevector1 && son_iguales!=0;i++){

            if(vector1[i] != vector2[i]){
                son_iguales = 0;
            }
        }
    } else{
        son_iguales = 0;
    }

    return son_iguales;
    
}

uint32_t iesimo(vector_t* vector, size_t index) {
    if (index>vector->size){
        return 0;
    }else{
        return vector->array[index];
    }
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out)
{
    if(index <= vector->size){
        *out=vector->array[index];
    }  
    
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    vector_t* ptr = NULL;
    uint32_t mayor = 0;
    
    for (uint64_t i = 0; i < longitud_del_array; i++){
        if ((array_de_vectores[i]->size) > mayor) {
            ptr = array_de_vectores[i];
            mayor = array_de_vectores[i]->size;
        }
    }
    
    return ptr;
}
