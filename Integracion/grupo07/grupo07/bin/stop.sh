#!/bin/sh
# Este script detiene el script pasado por parametro
# solo si este se encuentra en ejecucion actualmente
#ACLARACION: Las lineas comentadas con doble # posiblemente no se utilicen. 
#			 En cambio las comentadas con un solo # posiblemente si se utilicen
#Valido cantidad de parametros ingresados
if [ $# -ne "1" ]; then
	echo "Cantidad de parametros incorrecta"
	exit 1
fi

proceso=`ps -C "$1" | wc -l` 
if [  "$proceso" -gt "1" ] 
then
	# se supone que stop se encuentra en la misma carpeta que
	# el script a detener (BINDIR)
	
	##pidof "$1.sh"
	#matar=$(kill -9 $(pidof "$1.sh"))
	#El proceso se esta ejecutando, para matarlo busco su PID y le realizo kill -9
	matar=$(kill -9 $(pidof "$1"))
	# Verifico que se haya finalizado el proceso
	if [[ "$matar" -eq "0" ]]; then
		echo "Se finalizo correctamente el proceso $1"
		exit 0
	else
		echo "No se pudo finalizar correctamente el proceso $1"
		exit 2
	fi

#Valido que el proceso se este ejecutando.Se compara contra 1 porque el mismo grep "proceso" ya cuenta como un proceso
elif [[ "$proceso" -eq "1" ]]; then
	echo "El proceso $1 no se esta ejecutando"
	exit 3
fi
