#funcion de log para usar en el tp.
#Para llamarla(ejemplo):

# log $0 "WAR" "Inicio de log"

#Fijense que $0 es la funcion caller que lo llama.

log() {

	if [ $# -lt "3" ]
	then
		echo $#
		return -1
	fi
	FILE="Installer.log"
	CALLER="$1"
	ERRTYPE="$2"
	ERRMSG="$3"
	DATE=$(date +"%d/%m/%Y - %H:%M:%S")
	echo -e "\n--------------------------------------------------------$DATE--------------------------------------------------------\n\nUser: $USER\nCaller: $CALLER\nType: $ERRTYPE\nMessage: $ERRMSG\n\n-------------------------------------------------------------------------------------------------------------------------------------" >> $FILE
	

}

log "$0" WAR "Gaston es gay, muy gay. P.D:Fabri traidor" #Esto es un ejemplo de llamada. sacarlo.
