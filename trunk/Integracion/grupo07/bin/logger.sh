#Funcion usada para loggear mensajes
log() {

	if [ $# -lt "3" ]
	then
		echo $#
		return -1
	fi
	FILE="../conf/installer.log"
	CALLER="$1"
	ERRTYPE="$2"
	ERRMSG="$3"
	DATE=$(date +"%d/%m/%Y - %H:%M:%S")
	echo -e "\n--------------------------------------------------------$DATE--------------------------------------------------------\n\nUser: $USER\nCaller: $CALLER\nType: $ERRTYPE\nMessage: $ERRMSG\n\n-------------------------------------------------------------------------------------------------------------------------------------" >> $FILE
	

}


#Inicializo archivo de log
initializeLog() {

	echo -e "Inicia ejecucion de Installer\n"
	log $0 "INFO" "Inicia ejecucion de Installer"
	echo -e "Log de instalacion: grupo07/conf/installer.log\n"
	log $0 "INFO" "Log de instalacion: grupo07/conf/installer.log"
	echo -e "Directorio de configuracion: grupo07/conf\n"
	log $0 "INFO" "Directorio de configuracion: grupo07/conf"

}

