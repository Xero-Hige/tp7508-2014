#!/usr/bin/env bash
# Este script ejecuta el script pasado por parametro
# solo si este no se encuentra en ejecucion actualmente


#Valido cantidad de parametros ingresados
if [ $# -ne "2" ]; then
	echo "Cantidad de parametros incorrecta"
	exit 1
fi
#Verifico que este inicializado el ambiente
#ENVIRONMENT=1 #solo para probar
if [ "$ENVIRONMENT" -ne "1" ]; then
	echo "El ambiente no está inicializado"
	exit 2
fi

proceso=`ps -C "$1" | wc -l`

if [ "$proceso" -gt "1" ] 
	then
	#El proceso se esta ejecutando
	echo "El proceso $1 ya se esta ejecutando"
	exit 3
else
	#Sino lo ejecuto
	# se supone que start se encuentra en la misma carpeta que
	# el script a ejecutar (BINDIR)
	#`./"$1.sh"`
	if [ "$2" == "B" ]	# B=Back, se ejecuta de fondo
	then
		$(./"$1" &) 2>/dev/null
		exit 0
	elif [ "$2" == "T" ] # T=Top, se ejecuta en la superficie
	then
		echo -e "Se activará el $1. Para detenerlo, ejecutar en la terminal:"
		echo -e "./stop.sh $1\n"
		$(./"$1")  2>/dev/null	#Ver mutear los mensajes de finalizacion del proceso no trae problemas
		exit 0
	else
		echo "Argumentos incorrectos"
	fi
	exit 0
fi
