#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void classify_chars_in_string(char* string, char** vowels_and_cons) {
    uint8_t i=0;
    uint8_t j=0;
    uint8_t k=0;
    

    while(string[i] != '\0'){
        if(string[i] == 'a' || string[i] == 'e' || string[i] == 'i' || string[i] == 'o' || string[i] == 'u'){
            vowels_and_cons[0][j]=string[i];
            j++;
        }else{
            vowels_and_cons[1][k]=string[i];
            k++;
        }
        i++;
    }

    vowels_and_cons[0][j] = '\0';
    vowels_and_cons[1][k] = '\0';
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for(uint64_t i = 0; i < size_of_array; i++){
        array[i].vowels_and_consonants=malloc(2*sizeof(char*));
        array[i].vowels_and_consonants[0]=malloc(strlen(array[i].string)*sizeof(char) + 1);//vocales
        array[i].vowels_and_consonants[1]=malloc(strlen(array[i].string)*sizeof(char) + 1);//consonantes

        classify_chars_in_string(array[i].string,array[i].vowels_and_consonants);
    }
  

}