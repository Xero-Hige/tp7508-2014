#!/usr/bin/env bash
# Este script detiene el script pasado por parametro
# solo si este se encuentra en ejecucion actualmente
#ACLARACION: Las lineas comentadas con doble # posiblemente no se utilicen. 
#			 En cambio las comentadas con un solo # posiblemente si se utilicen
#Valido cantidad de parametros ingresados
if [ $# -ne "1" ]; then
	echo "Cantidad de parametros incorrecta"
	exit 1
fi

proceso=`ps -ef | grep "./$1" | grep "bash" | grep -v "grep" | wc -l` 
if [  "$proceso" -eq "1" ] 
then
	# se supone que stop se encuentra en la misma carpeta que
	# el script a detener (BINDIR)
	
	##pidof "$1.sh"
	#matar=$(kill -9 $(pidof "$1.sh"))
	#El proceso se esta ejecutando, para matarlo busco su PID y le realizo kill -9
	#pid=$(pidof "$1")
	pid=`ps -ef | grep "./$1" | grep "bash" | grep -v "grep" | awk '{print $2}'`
	kill -9 "$pid" > /dev/null 2>&1
	wait "$pid" > /dev/null 2>&1
	sleep 1s
	# Verifico que se haya finalizado el proceso
	#if [ "$matar" -eq "0" ]
	proceso1=`ps -ef | grep "./$1" | grep "bash" | grep -v "grep" | wc -l` 
	if [ "$proceso" -gt "$proceso1" ]
	then
		echo "Se finalizo correctamente el proceso $1"
		exit 0
	else
		echo "No se pudo finalizar correctamente el proceso $1"
		exit 2
	fi

#Valido que el proceso se este ejecutando.Se compara contra 1 porque el mismo grep "proceso" ya cuenta como un proceso
elif [[ "$proceso" -lt "1" ]]; then
	echo "El proceso $1 no se esta ejecutando"
	exit 3
fi
