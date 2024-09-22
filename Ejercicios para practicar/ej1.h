#ifndef __EJ1__
#define __EJ1__
#include <stddef.h>
#include <stdint.h>

/*returns the number corresponding to the letter
(A=0,Z=25)*/
uint8_t ord(char letter);
/*returns the letter correspondign to the number*/
char chr(uint8_t num);
/*precondition: only reciebes CAPS letters*/ 
char* cesarCodSimple(char* frase, uint32_t x);
/*precondition: only reciebes CAPS letters*/ 
char* codificationCesar(char*frase,uint32_t x);
#endif