# Este script ejecuta el script pasado por parametro
# solo si este no se encuentra en ejecucion actualmente


#Valido cantidad de parametros ingresados
if [ $# -ne "1" ]; then
	echo "Cantidad de parametros incorrecta"
	exit 1
fi
#Verifico que este inicializado el ambiente
ENVIRONMENT=1 #solo para probar
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
	$(./"$1")
	exit 0
fi
