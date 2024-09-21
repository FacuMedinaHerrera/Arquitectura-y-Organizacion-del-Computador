CFLAGS += -std=c11 -Wall -Wextra -O0 -ggdb -lm -Wno-unused-variable -Wno-unused-parameter -no-pie
CC:=gcc
NASM:=nasm
NASMFLAGS:=-f elf64 -g -F DWARF
TARGETS:= test_ej1
#Regla Principal
all: $(TARGETS)
#Regla para ejecutar los tests
RUN := $(patsubst %,run_%, $(TARGETS))
#Limpieza
clean:
	rm -f *.o $(TARGETS)
#chequeo de errores de memoria
$(RUN): run_%: % 
	valgrind --show-reachable=yes --leak-check=full --error-exitcode=1 ./$* \
	&& echo "No se detectaron errores de memoria" 
#compilacion de c y ensamblado de ASM

test_ej1: test_ej1.o ej1_asm.o ej1.o 
	$(CC) $(CFLAGS) $^ -o $@

#Reglas para generar los archivos objeto
test_ej1.o: test_ej1.c
	$(CC) $(CFLAGS) $< -o $@
ej1.o: ej1.c
	$(CC) $(CFLAGS) $< -o $@
ej1_asm.o: ej1_asm.asm
	$(NASM) $(NASMFLAGS) $< -o $@
.PHONY: all clean $(RUN)



# Pequeña guia de Makefile:
#    Se declara variables con NOMBRE_VARIABLE := declaración o NOMBRE_VARIABLE += declaración
#    Se utiliza variables declaradas mediante $(NOMBRE_VARIABLE)
#
#    Para declarar un target (que podrá ser llamado mediante make nombre_target) se utiliza la siguiente sintaxis:
#    nombre_target: dependencia1 dependencia2 dependencia3 
#    	comandos
#	 Se correrán los targets asociados a las dependencias antes de ejecutar el código de la dependencia actual	
#
#    En el cuerpo del target, entre otros, se pueden utilizar las siguientes variables mágicas:
#       $@ equivale a nombre_target
#       $^ equivale a todas las dependencias
#       $< equivale a la primer dependencia
#    Cheatsheet completa: https://devhints.io/makefile

# Declaramos variables

# Target default, corre todos los targets de compilación, que declaramos en la variable TARGETS


# Declara targets run_tests_vector, run_tests_contar_espacios, run_tests_lista_enlazada, run_tests_classify_chars
# Que permiten correr los tests con valgrind

# Target para borrar binarios compilados y archivos objeto


# Crea targets declarados en la variable RUN
# Corre el binario correspondiente con valgrind (el nombre del binario corrido sera la parte después de run_ del target)
# Esto obedece una Static Pattern Rule, que limita la regla del target a los archivos especificados por la variable (en este caso RUN)
# Todos los archivos de RUN se evaluan contra la expresión posterior (run_%) y se extrae la "stem" a la expresión %.
# Usamos esa expresión para armar las dependencias (en este caso los binarios tests_lista_enlazada, tests_vector, etc).
# En el cuerpo del target, la stem extraída (antes %) se puede acceder con la expresión $* (ya no con %)
# Más información: https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html


# Las flags de compilación con las que deben llamar a gcc están dadas en la variable CFLAGS
# Se dejan las dependencias de este primer target como ejemplo; completar para los demás