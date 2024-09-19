#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    lista_t* nuevaLista= malloc(sizeof(lista_t));// Declaro la lista
    nuevaLista->head=NULL;
    return nuevaLista;
    
}

uint32_t longitud(lista_t* lista) {
    uint32_t i = 0;
    nodo_t* nodoActual = lista->head;

    if (lista == NULL) {
        return i;
    }
    
    while (nodoActual != NULL){
        nodoActual = nodoActual->next;
        i++;
    }
    return i;

}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
    if(lista->head == NULL){
        lista->head=malloc(sizeof(nodo_t));
        lista->head->arreglo=malloc(sizeof(arreglo)*longitud);
            for(uint64_t i=0 ; i<longitud;i++){
            lista->head->arreglo[i]=arreglo[i];
        }
        lista->head->longitud=longitud;
        lista->head->next=NULL;
    }else{
        nodo_t* actual=lista->head;
        nodo_t* anterior=actual;
        while(actual!=NULL){
            anterior=actual;
            actual=actual->next;
        }
        actual = malloc(sizeof(nodo_t));
        anterior->next = actual;
        actual->longitud = longitud;
        actual->arreglo = malloc(sizeof(arreglo)*longitud);
        for(uint64_t i=0 ; i<longitud;i++){
            actual->arreglo[i]=arreglo[i];
        }
        actual->next = NULL;
    }
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
    uint32_t j=0;
    if(lista==NULL){
        return NULL;
    }
    while(lista->head!=NULL && j != i){
        lista->head=lista->head->next;
        j++;
    }
    return lista->head;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {

    uint64_t longitudTotal=0;

    nodo_t* actual = lista->head;
    
    while(actual!=NULL){
        longitudTotal+=actual->longitud;
        actual=actual->next;
    }
    
    return longitudTotal;
}

void imprimir_lista(lista_t* lista) {
    if(lista->head==NULL){
        printf("null");
    }


    while (lista->head != NULL){
        printf("| %ld | -> ",(lista->head->longitud));
        lista->head = lista->head->next;
        if(lista->head == NULL){
            printf("null");
        }
    }

}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
    int contenido = 0;

    for (size_t i = 0; i < size_of_array; i++) {
        if (array[i] == elemento_a_buscar){
            contenido = 1;
            return contenido;
        }
}
return contenido;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
    int contiene_elemento = 0;
    nodo_t* actual = lista->head;

    while (actual != NULL){
        if (array_contiene_elemento(actual->arreglo, actual->longitud, elemento_a_buscar) == 1) {
            contiene_elemento = 1;
            return contiene_elemento;
        }
        actual = actual->next;
    }

return contiene_elemento;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
    nodo_t* aBorrar = lista->head;
    nodo_t* siguiente = aBorrar;
    
    while (siguiente != NULL) {
        siguiente = aBorrar->next; //paso al siguiente nodo
        free(aBorrar->arreglo); //libero memoria pedida para el array
        //actual->arreglo = NULL; //Seteo el puntero a null para evitar dangling pointer
        free(aBorrar);
        aBorrar=siguiente;
    }

    free(lista); //libero memoria pedida para la lista
    //lista = NULL; //asigno null al puntero de la lista

}