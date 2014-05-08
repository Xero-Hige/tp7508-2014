source logger.sh



#Checkeo existencia de Intaller.conf
checkInstallerConfFile() {
	
	if [ ! -f "$ROOT/$CONFGFILE" ]
	then
		log "$0" "WAR" "El archivo de configuracion (installer.conf) no existe, el paquete no fue instalado, se procede con la instalacion desde cero"
		return 0
	else
		log "$0" "WAR" "El archivo de configuracion (installer.conf) ya existe, se checkean directorios"
		return 1
	fi
}


#Checkea que ya haya sido creado el directorio($1 son los caracteres que lo identifican)
checkCreated() {
	
	grep -q "$1" "$ROOT/$CONFGFILE"
	if [ $? -eq "0" ]
	then 
		return 1 #El dir existe
	else
		return 0 #El dir no existe
	fi

}

#lee el archivo de configuracion y le asigna el nuevo valor a la variable($1 sera el nombre de la variable, si $2 existe, se toma el nuevo valor de ahi)
changeValue() {
	
	if [ "$#" -eq "2" ]
	then
		if [ "$2" != "" ]
		then
			NEWVALUE="$2"
		else
			NEWVALUE="${!1}"
		fi
	else
		NEWVALUE=$(grep "$1" "$ROOT/$CONFGFILE" | sed "s/^.*=\([^=]*\)=.*=.*$/\1/" )
	fi
	if [ "$1" == "BINDIR" ]
	then
		BINDIR="$NEWVALUE"
	elif [ "$1" == "MAEDIR" ]
	then
		MAEDIR="$NEWVALUE"
	elif [ "$1" == "NOVEDIR" ]
	then
		NOVEDIR="$NEWVALUE"
	elif [ "$1" == "DATASIZE" ]
	then
		DATASIZE="$NEWVALUE"
	elif [ "$1" == "ACEPDIR" ]
	then
		ACEPDIR="$NEWVALUE"
	elif [ "$1" == "INFODIR" ]
	then
		INFODIR="$NEWVALUE"
	elif [ "$1" == "RECHDIR" ]
	then
		RECHDIR="$NEWVALUE"
	elif [ "$1" == "LOGDIR" ]
	then
		LOGDIR="$NEWVALUE"
	elif [ "$1" == "LOGEXT" ]
	then
		LOGEXT="$NEWVALUE"
	elif [ "$1" == "LOGSIZE" ]
	then
		LOGSIZE="$NEWVALUE"	
	fi
}


#Obtiene la descripcion de la variable($1 sera el nombre de la variable)
getVarInfo() {
	
	echo $(grep "$1" "vars.def" | sed "s/^[^:]*://")

}

#Si el archivo installer.conf existe se debera checkear que la instalacion este completa. Si lo esta, se termina. Si no, se muestran los que ya estan definidos y los faltantes.Hay que logear todo 
checkCompleteInstallation() {

	MESSAGE+="\n\nTP S07508 Primer Cuatrimestre 2014. Tema C Copyright Grupo 07\n\n"
	NOTINSTALLED="\nCOMPONENTES FALTANTES: "
	NEWPATH=""
	for dir in "${INSTALLERVARIABLES[@]}"
	do
		checkCreated $dir
		if [ $? -eq "0" ]
		then 
			NOTINSTALLED+=$(getVarInfo "$dir")
			NOTINSTALLED+="; "
		else
			if [ "$dir" == "DATASIZE" ] || [ "$dir" == "LOGEXT" ] || [ "$dir" == "LOGSIZE" ]
			then
				continue
			else
				changeValue "$dir"
				NEWPATH="${!dir}"
				if [ -d "$ROOT/$NEWPATH" ] #checkeo que el directorio que estaba guardado en el archivo de configuracion exista
				then #existe
					MESSAGE+=$(getVarInfo "$dir")
					MESSAGE+=": $NEWPATH\n"
					MESSAGE+=$(ls "$ROOT/$NEWPATH")
					MESSAGE+="\n"
				else #no existe
					NOTINSTALLED+=$(getVarInfo "$dir")
					NOTINSTALLED+="; "
				fi
			fi
		fi
	done
	
	if [ "$NOTINSTALLED" == "\nCOMPONENTES FALTANTES: " ]
	then
		MESSAGE+="Estado de la instalacion: COMPLETA\n"
		return 0 #la instalacion estaba completa
	else
		MESSAGE+="$NOTINSTALLED"
		return 1 #la instalacion estaba incompleta
	fi

}


#checkea que el espacio en el directorio($1) sea mayor al pedido($2)
checkDiskSpace() {

	#primero checkea que exista el directorio
	if [ -d "$1" ]
	then
		DIRSZ=$(df -h -B MB "$1" |grep  "[0-9][0-9]MB" | sed "s/^[^ ]* *[^ ]* *[^ *]* *\([^ ]*\)MB.*$/\1/")
		if [ "$DIRSZ" -gt "$2" ]
		then 
			log $0 "INFO" "El espacio en disco disponible es sufieciente\n\n"
			echo -e "\nEl espacio en disco disponible es sufieciente\n"
			return 0 #el tamanio es suficiente
		else
			log $0 "WAR" "\nInsuficiente espacio en disco\nEspacio disponible: $DIRSZ Mb.\nEspacio requerido: $2 Mb.\nCancele la instalacion o intentelo nuevamente\n"
			echo -e "\nInsuficiente espacio en disco\nEspacio disponible: $DIRSZ Mb.\nEspacio requerido: $2 Mb.\nCancele la instalacion o intentelo nuevamente\n"
			return 1 # el tamanio no es suficiente
		fi
	fi
	return 2 #el directorio no existe
		
}



#Completa la instalacion pidiendole los valores al usuario
askDirPaths() {
	for dir in "${INSTALLERVARIABLES[@]}"
	do
		VARINFO=$(getVarInfo "$dir")
		if [ "$dir" == "DATASIZE" ]
		then
			log $0 "INFO" "Se pide al usuario definir el $VARINFO (${!dir}Mb)\n\n"
			while true
			do
				echo -e "Defina el $VARINFO (${!dir}Mb)\n"
				read NP
				if [[ ! "$NP" =~ ^[0-9]+$ ]] && [ "$NP" != "" ]
				then
					echo -e "Ingrese valor nuemerico"
					continue
				fi
				if [ "$NP" == "" ]
				then
					NP="${!dir}"
				fi
				checkDiskSpace "$ROOT" "$NP"
				if [ "$?" -eq "0" ]
				then
					break
				fi
			done
		
		elif [ "$dir" == "LOGSIZE" ]
		then
			log $0 "INFO" "Se pide al usuario definir el $VARINFO (${!dir}Kb)\n"
			while true
			do
				echo -e "Defina el $VARINFO (${!dir}Kb)\n"
				read NP
				if [[ ! "$NP" =~ ^[0-9]+$ ]] && [ "$NP" != "" ]
				then
					echo -e "Ingrese valor nuemerico"
					continue
				fi
				break
			done
		else	
			if [ "$dir" == "LOGEXT" ]
			then
				echo -e "Defina la $VARINFO ($GRUPO07/$LOGDIR/log.<${!dir}>)\n"
				log $0 "INFO" "Se pide al usuario definir la $VARINFO ($GRUPO07/$LOGDIR/log.<${!dir}>)\n"
			else		
				echo -e "Defina el $VARINFO ($GRUPO07/${!dir})\n"
				log $0 "INFO" "Se pide al usuario definir el $VARINFO ($GRUPO07/${!dir})\n"
			fi		
			read NP
		fi
		changeValue "$dir" "$NP"
	done
						
}

updateConfFile() {
	
	echo -e "Actualizando la configuracion del sistema\n"
	INSTALLERVARIABLES=("${INSTALLERVARIABLES[@]}" GRUPO CONFDIR INFON)
	if [ -f "$ROOT/$CONFGFILE" ]
	then
		for dir in "${INSTALLERVARIABLES[@]}"
		do
			CURRENT=$(grep "$dir" "$ROOT/$CONFGFILE" | sed "s/^$dir=\([^=]*\).*$/\1/")
			if [ "$CURRENT" != "${!dir}" ] #si cambio
			then
				DATE=$(date +"%d-%m-%Y  %H:%M:%S")
				if [ "$CURRENT" == "" ] #no estaba en el archivo de configuracion  
				then
					echo "$dir=${!dir}=$USER=$DATE" >> "$ROOT/$CONFGFILE"
				else	
					sed -i "s/^$dir.*$/$dir=${!dir}=$USER=$DATE/" "$ROOT/$CONFGFILE"
				fi		
			fi
		done
		
	else
		for dir in "${INSTALLERVARIABLES[@]}"
		do
			DATE=$(date +"%d-%m-%Y  %H:%M:%S")
			echo "$dir=${!dir}=$USER=$DATE" >> "$ROOT/$CONFGFILE"
		done
	fi	

}


