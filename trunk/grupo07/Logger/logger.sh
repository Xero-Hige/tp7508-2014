#Funcion usada para loggear mensajes
log() {

	if [ $# -lt "3" ]
	then
		echo $#
		return -1
	fi
	FILE="../Conf/Installer.log"
	CALLER="$1"
	ERRTYPE="$2"
	ERRMSG="$3"
	DATE=$(date +"%d/%m/%Y - %H:%M:%S")
	echo -e "\n--------------------------------------------------------$DATE--------------------------------------------------------\n\nUser: $USER\nCaller: $CALLER\nType: $ERRTYPE\nMessage: $ERRMSG\n\n-------------------------------------------------------------------------------------------------------------------------------------" >> $FILE
	

}


#Inicializo archivo de log
initializeLog() {

	echo "Inicia ejecucion de Installer"
	log $0 "INFO" "Inicia ejecucion de Installer"
	echo "Log de instalacion: grupo07/Conf/Installer.log"
	log $0 "INFO" "Log de instalacion: grupo07/Conf/Installer.log"
	echo "Directorio de configuracion: grupo07/Conf"
	log $0 "INFO" "Directorio de configuracion: grupo07/Conf"

}

