# Este script detiene el script pasado por parametro
# solo si este se encuentra en ejecucion actualmente
proceso=`ps -ef | grep "$1.sh" | wc  -l`

if [ ! "$proceso" -gt "1" ] 
then
	# se supone que stop se encuentra en la misma carpeta que
	# el script a detener (BINDIR)
	pidof "$1.sh"
	#FALTA
fi
