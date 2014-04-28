source RWConfFile.sh


#checkea que perl este instalado y su version sea igual o mayos a la v5
checkPerl() {

	echo -e "\nCheckeando que perl 5 o superior este instalado...\n"
	log $0 "INFO" "\nCheckeando que perl 5 o superior este instalado...\n"
	MESSAGE=$(perl -v)
	if [ "$?" -ne "0" ]
	then
		echo -e "\n     TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 07\nPara instalar el TP es necesario contar con Perl 5 o superior. Efectúe su instalación e inténtelo nuevamente.\nProceso de Instalación Cancelado"
		log $0 "ERR" "\n     TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 07\nPara instalar el TP es necesario contar con Perl 5 o superior. Efectúe su instalación e inténtelo nuevamente.\nProceso de Instalación Cancelado"
		return 1
	else #perl existe se checkea la version
		VERSION=$(echo "$MESSAGE" | grep "v[0-9]*\.[0-9]*\.[0-9]*"  | sed "s/^.*v\([0-9]\)*\.[0-9]*\.[0-9]*.*$/\1/")
		if [ "$VERSION" -ge "5" ]
		then
			echo -e "Perl se encuentra instalado:\n $MESSAGE\n"
			log $0 "INFO" "Perl se encuentra instalado\n $MESSAGE"
			return 0
		else
			echo -e "Perl se encuentra instalado pero la version es menor a la requerida\n$MESSAGE\nCancelando instalacion..."
			log $0 "ERR" "Perl se encuentra instalado pero la version es menor a la requerida\n$MESSAGE\nCancelando instalacion..."
			return 1
		fi
	fi	
} 

#checkea que termine el proceso de instalacion
checkEnd() {
	if [ "$1" -ne "0" ]
	then
		exit
	fi
}

#Le pregunta la usuario si acepta los terminos y condiciones para seguir con la instalacion
checkTerminosYCondiciones() {

	echo -e "                 \nTP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 07\n\n Al instalar TP SO7508 Primer Cuatrimestre 2014 UD. expresa aceptar los términos y condiciones del ACUERDO DE LICENCIA DE SOFTWARE incluido en este paquete.\nAcepta?(Y-N)"
	log $0 "INFO" "Se muestran terminos y condiciones"
	RESPONSE=0		
	while [ "$RESPONSE" -eq "0" ]
	do
		read R
		if [ "$R" == "y" ] || [ "$R" == "Y" ]
		then 
			log $0 "INFO" "El usuario acepta terminos y condiciones, se procede con las intalacion"
			RESPONSE=1
		elif [ "$R" == "n" ] || [ "$R" == "N" ]
		then 
			log $0 "INFO" "El usuario no acepta terminos y condiciones, se cancela la instalacion"
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
		log $0 "INFO" "El programa no fue instalado, se procede con las instalacion\n"
		return 0 #se sigue con la instalacion
	else
		echo -e "El programa ya fue instalado\nCheckeando directorios...\n"
		log $0 "INFO" "El programa ya fue instalado\nCheckeando directorios...\n"
		MESSAGE=$(checkCompleteInstallation)
		if [ "$?" -eq "0" ] #la instalacion estaba completa
		then
			MESSAGE+="\nProceso de instalacion cancelado\n"			
			log $0 "INFO" "$MESSAGE"
			echo -e "$MESSAGE"
			return 1 #se cancela la instalacion
		else # la instalacion no estaba completa
			log $0 "WAR" "$MESSAGE"
			echo -e "$MESSAGE"
			RESPONSE=0			
			while [ "$RESPONSE" -eq "0" ]
			do
				echo -e "Estado de instalacion: INCOMPLETA\nDesea completar la instalacion?(Y-N)"
				read R
				if [ "$R" == "y" ] || [ "$R" == "Y" ]
				then 
					log $0 "INFO" "El usuario elige continuar con la instalacion"
					RESPONSE=1 
					return 0	
				elif [ "$R" == "n" ] || [ "$R" == "N" ]
				then 
					log $0 "INFO" "El usuario elige cancelar la instalacion"
					RESPONSE=2
					return 1
				else
					echo -e "\nIngrese una opcion correcta(Y-N)\n"
				fi
			done
		fi
	fi

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

R="$?" #lo que devolvio checkPreviouslyInstalled

checkEnd "$R"

#checkea que perl este instalado
checkPerl

R="$?" #lo que devuelve checkPerl

checkEnd "$R"

#completa la instalacion pidiendole los datos al usuario
completeInstallation
