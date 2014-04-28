source RWConfFile.sh




#PASOS

#Inicio archivo de Log
initializeLog

#Checkeo el archivo de configuracion
checkInstallerConfFile

#si el archivo de configuracion esta instalado y completo, checkeo que este correctamente. Si no pido los datos
if [ "$?" -eq "0" ]
then
	echo -e "El programa no fue instalado, se procede con las instalacion\n"
else
	echo -e "El programa ya fue instalado\nCheckeando directorios...\n"
	MESSAGE=$(checkCompleteInstallation)
	if [ "$?" -eq "0" ] #la instalacion estaba completa
	then
		MESSAGE+="\nProceso de instalacion cancelado\n"			
		log $0 "INFO" "$MESSAGE"
		echo -e "$MESSAGE"
		break
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
				RESPONSE=1
			elif [ "$R" == "n" ] || [ "$R" == "N" ]
			then 
				RESPONSE=1
			else
				echo -e "\nIngrese una opcion correcta(Y-N)\n"
			fi
		done
	fi
fi
