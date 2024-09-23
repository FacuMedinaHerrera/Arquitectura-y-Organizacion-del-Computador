#include "ej1.h"

nodo_display_list_t* inicializar_nodo(
  uint8_t (*primitiva)(uint8_t x, uint8_t y, uint8_t z_size),
  uint8_t x, uint8_t y, nodo_display_list_t* siguiente) {
    nodo_display_list_t* nuevo = malloc(sizeof(nodo_display_list_t));
    nuevo->primitiva=primitiva;
    nuevo->x=x;
    nuevo->y=y;
    nuevo->siguiente=siguiente;
  return nuevo;
}

ordering_table_t* inicializar_OT(uint8_t table_size) {
  ordering_table_t* nuevo=malloc(sizeof(ordering_table_t));
  nuevo->table_size=table_size;
  if(table_size!=0){
    nuevo->table=malloc(table_size*sizeof(nodo_ot_t));
  }
  return nuevo;
}

void calcular_z(nodo_display_list_t* nodo, uint8_t z_size) {
  nodo->z=nodo->primitiva(nodo->x,nodo->y,z_size);
}

void ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) {

  while(display_list!=NULL){
    calcular_z(display_list,ot->table_size);
    uint8_t z=display_list->z;

      if( ot->table[z] == NULL) {
        ot->table[z]=malloc(sizeof(nodo_ot_t));
        ot->table[z]->display_element=display_list;
       ot->table[z]->siguiente=NULL;
      }else{
        ot->table[z]->display_element=display_list;
        
      }
        
    display_list=display_list->siguiente;
  }
}
