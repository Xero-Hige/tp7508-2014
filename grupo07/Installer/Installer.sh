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


#Checkeo existencia de Intaller.conf
checkInstallerConfFile() {
	
	if [ ! -f "../Conf/Installer.conf" ]
	then
		log "$0" "WAR" "El archivo de configuracion (Installer.conf) no existe, el paquete no fue instalado, se procede con la instalacion desde cero"
		return 0
	else
		log "$0" "WAR" "El archivo de configuracion (Installer.conf) ya existe, se checkean directorios"
		return 1
	fi
}


