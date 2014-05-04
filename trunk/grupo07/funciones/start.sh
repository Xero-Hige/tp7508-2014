# Este script ejecuta el script pasado por parametro
# solo si este no se encuentra en ejecucion actualmente
proceso=`ps -ef | grep "$1.sh" | wc  -l`

if [ ! "$proceso" -gt "1" ] 
then
	# se supone que start se encuentra en la misma carpeta que
	# el script a ejecutar (BINDIR)
	`./"$1.sh"`
fi
