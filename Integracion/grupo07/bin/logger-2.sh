#Funcion usada para loggear mensajes
log() {

	if [ $# -lt "4" ]
	then
		echo $#
		return -1
	fi

	who="$USER"	
	where="$1"
	what="$2"
	why="$3"
	when=$(date +"%d/%m/%Y - %H:%M:%S")
	
	log_file="$LOGDIR"/"$4"."$LOGEXT"

	echo -e "[$when]\tUser: $who\tCaller: $where \tType: $what\nMessage: $why" #>> $log_file
}


#Inicializo archivo de log
initializeLog() {

	echo "Inicia ejecucion de Installer"
	log $0 "INFO" "Inicia ejecucion de Installer"
	echo "Log de instalacion: grupo07/conf/installer.log"
	log $0 "INFO" "Log de instalacion: grupo07/conf/installer.log"
	echo "Directorio de configuracion: grupo07/conf"
	log $0 "INFO" "Directorio de configuracion: grupo07/conf"

}

