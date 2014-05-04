source RWConfFile.sh
source dirManager.sh





MESSAGE=""
ROOT=".."
GRUPO07="grupo07"
CONFDIR="conf"
CONFGFILE="conf/installer.conf"
BINDIR="bin" #de instalacion de ejecutables
MAEDIR="mae" #de archivos maestros
NOVEDIR="nov" #arribos de de novedades
DATASIZE=100 #espacio minimos en mb para NOVEDIR
ACPTDIR="acpt" #novedades aceptadas
INFODIR="info" #reportes
RECHDIR="rech" #archivos rechazados
LOGDIR="log" #directorio de log
LOGEXT="log" #extension de archivos de log
LOGSIZE=400 #tamanio maximo para archivos de log
INSTALLERVARIABLES=( BINDIR MAEDIR NOVEDIR DATASIZE ACPTDIR INFODIR RECHDIR LOGDIR LOGEXT LOGSIZE )

#checkea que perl este instalado y su version sea igual o mayos a la v5
checkPerl() {

	echo -e "\nCheckeando que perl 5 o superior este instalado...\n"
	log "$0" "INFO" "\nCheckeando que perl 5 o superior este instalado...\n"
	MSG=$(perl -v)
	if [ "$?" -ne "0" ]
	then
		echo -e "\nTP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 07\nPara instalar el TP es necesario contar con Perl 5 o superior. Efectúe su instalación e inténtelo nuevamente.\nProceso de Instalación Cancelado"
		log "$0" "ERR" "\n     TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 07\nPara instalar el TP es necesario contar con Perl 5 o superior. Efectúe su instalación e inténtelo nuevamente.\nProceso de Instalación Cancelado"
		return 1
	else #perl existe se checkea la version
		VERSION=$(echo "$MSG" | grep "v[0-9]*\.[0-9]*\.[0-9]*"  | sed "s/^.*v\([0-9]\)*\.[0-9]*\.[0-9]*.*$/\1/")
		if [ "$VERSION" -ge "5" ]
		then
			echo -e "Perl se encuentra instalado:\n $MSG\n"
			log "$0" "INFO" "Perl se encuentra instalado\n $MSG"
			return 0
		else
			echo -e "Perl se encuentra instalado pero la version es menor a la requerida\n$MSG\nCancelando instalacion..."
			log "$0" "ERR" "Perl se encuentra instalado pero la version es menor a la requerida\n$MSG\nCancelando instalacion..."
			return 1
		fi
	fi	
} 

#checkea que termine el proceso de instalacion
checkEnd() { 
	if [ "$1" -eq "1" ]
	then
		exit 1
	fi
}

#Le pregunta la usuario si acepta los terminos y condiciones para seguir con la instalacion
checkTerminosYCondiciones() {

	echo -e "\nTP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 07\n\n Al instalar TP SO7508 Primer Cuatrimestre 2014 UD. expresa aceptar los términos y condiciones del ACUERDO DE LICENCIA DE SOFTWARE incluido en este paquete.\nAcepta?(Y-N)"
	log "$0" "INFO" "Se muestran terminos y condiciones"
	RESPONSE=0		
	while [ "$RESPONSE" -eq "0" ]
	do
		read R
		if [ "$R" == "y" ] || [ "$R" == "Y" ]
		then 
			log "$0" "INFO" "El usuario acepta terminos y condiciones, se procede con las intalacion"
			RESPONSE=1
		elif [ "$R" == "n" ] || [ "$R" == "N" ]
		then 
			log "$0" "INFO" "El usuario no acepta terminos y condiciones, se cancela la instalacion"
			RESPONSE=1
		else
			echo -e "\nIngrese una opcion correcta(Y-N)\n"
		fi
	done

}


#checkea si la hubo o no una instalacion previa y pregunta al usuario si quiere completarla.
checkPreviouslyInstalled() {

		
	if [ "$1" -eq "0" ]
	then
		echo -e "El programa no fue instalado, se procede con las instalacion\n"
		log "$0" "INFO" "El programa no fue instalado, se procede con las instalacion\n"
		return 0 #se sigue con la instalacion
	else
		echo -e "El programa ya fue instalado\nCheckeando directorios...\n"
		log "$0" "INFO" "El programa ya fue instalado\nCheckeando directorios...\n"
		checkCompleteInstallation
		if [ "$?" -eq "0" ] #la instalacion estaba completa
		then
			MESSAGE+="\nProceso de instalacion cancelado\n"			
			log "$0" "INFO" "$MESSAGE"
			echo -e "$MESSAGE"
			return 1 #se cancela la instalacion
		else # la instalacion no estaba completa
			log "$0" "WAR" "$MESSAGE"
			echo -e "$MESSAGE"
			RESPONSE=0			
			while [ "$RESPONSE" -eq "0" ]
			do
				echo -e "Estado de instalacion: INCOMPLETA\nDesea completar la instalacion?(Y-N)"
				read R
				if [ "$R" == "y" ] || [ "$R" == "Y" ]
				then 
					log "$0" "INFO" "El usuario elige continuar con la instalacion"
					RESPONSE=1 
					return 2	
				elif [ "$R" == "n" ] || [ "$R" == "N" ]
				then 
					log "$0" "INFO" "El usuario elige cancelar la instalacion"
					RESPONSE=2
					return 1
				else
					echo -e "\nIngrese una opcion correcta(Y-N)\n"
				fi
			done
		fi
	fi

}
	

#muestra los paths de las variables y pregunta si se queiere terminar la instalacion. Si es asi, completa la instalacion, sino, vuelve a pedir al usuario los directorios y pregunta si se quierer completar la instalacion de nuevo
endInstallation() {

	
	LIST=0 #si se listan los archivos
	while true
	do
		MESSAGE="\n\nTP S07508 Primer Cuatrimestre 2014. Tema C Copyright Grupo 07\n\n"
		for dir in "${INSTALLERVARIABLES[@]}"
		do
			MESSAGE+=$(getVarInfo "$dir")
			MESSAGE+=": ${!dir}"
			if [ "$dir" == "DATASIZE" ] 
			then
				MESSAGE+="Mb"
				LIST=1 #no se listan los archivos
			elif [ "$dir" == "LOGEXT" ]
			then
				LIST=1
			elif [ "$dir" == "LOGSIZE" ]
			then
				MESSAGE+="Kb"
				LIST=1
			else
				if [ -d "$ROOT/${!dir}" ]
				then
					LIST=0
				else
					LIST=1
				fi
			fi
			if [ "$LIST" -eq "0" ]
			then		
				MESSAGE+=$(ls "$ROOT/$NEWPATH")
			fi			
			MESSAGE+="\n"
		done
		MESSAGE+="Estado de instalacion: LISTA\n"
		MESSAGE+="Esta de acuerdo con los parametros mostrados?(Y-N): "
		echo -e "$MESSAGE"
		log "$0" "INFO" "$MESSAGE"
		RESPONSE=0		
		while [ "$RESPONSE" -eq "0" ]
		do
			read NP
			if [ "$NP" == "y" ] || [ "$NP" == "Y" ]
			then 
				log "$0" "INFO" "El usuario acepta, se completa la instalacion"
				RESPONSE=1
			elif [ "$NP" == "n" ] || [ "$NP" == "N" ]
			then 
				log "$0" "INFO" "El usuario no acepta, se piden de nuevo los valores"
				RESPONSE=2
			else
				echo -e "\nIngrese una opcion correcta(Y-N)\n"
			fi
		done
		if [ "$RESPONSE" -eq "2" ] #se contesta que si
		then
			askDirPaths
		else
			break
		fi
	done

}

#termina con las instalacion
finish() {

	echo -e "Iniciando Instalacion. Esta Ud. Seguro? (Y-N)\n"
	log "$0" "INFO" "Iniciando Instalacion. Esta Ud. Seguro? (Y-N)\n"
	RESPONSE=0
	while true
	do
		read NP
		if [ "$NP" == "y" ] || [ "$NP" == "Y" ]
		then 
			log "$0" "INFO" "El usuario acepta, se completa la instalacion"
			createDirs
			updateConfFile
			exit 0
		elif [ "$NP" == "n" ] || [ "$NP" == "N" ]
		then 
			log "$0" "INFO" "El usuario no acepta, se cancela la instalacion"
			exit 1
		else
			echo -e "\nIngrese una opcion correcta(Y-N)\n"
		fi
	done
	

}


#----------------------------------------------MAIN------------------------------------------------------------------------------------
#PASOS

#Inicio archivo de Log
initializeLog

#Checkeo el archivo de configuracion
checkInstallerConfFile
R="$?" #lo que devolvio checkInstallerConfFile


#Checkeo que haya sido instalado previamente
checkPreviouslyInstalled "$R"


R="$?" #lo que devolvio checkPreviouslyInstalled (0:no estaba instalado,hay que pedir directorios. 1:Estaba completa o estaba incompleta y no se quiere seguir, se va a FIN. 2: Estaba incompleta: Se quiere seguir.)

checkEnd "$R"


if [ "$R" -eq "2" ] # la instalacion estaba incompleta, hay que ir al final
then
	clear
	endInstallation #presenta los valores propuestos y pregunta si se quiere terminar
	finish
	exit
fi

#checkea que perl este instalado
checkPerl

R="$?" #lo que devuelve checkPerl

checkEnd "$R"

#le pide los datos al usuario
askDirPaths

#limpio la pantalla
clear

#presenta los valores propuestos y pregunta si se quiere terminar
endInstallation


