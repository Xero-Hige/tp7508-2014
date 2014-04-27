ROOT=".."
GRUPO07="grupo07"
CONFDIR="Conf"
CONFGFILE="Conf/Installer.conf"
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

#lee el archivo de configuracion y le asigna el nuevo valor a la variable($1 sera el nombre de la variable)
changeValue() {
	
	NEWVALUE=$(grep "$1" "$ROOT/$CONFGFILE" | sed "s/^.*=\([^=]*\)=.*=.*$/\1/" )

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
	elif [ "$1" == "ACPTDIR" ]
	then
		ACPTDIR="$NEWVALUE"
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
	echo $NEWVALUE
}


#Obtiene la descripcion de la variable($1 sera el nombre de la variable)
getVarInfo() {
	
	echo $(grep "$1" "vars.def" | sed "s/^[^:]*://")

}

#Si el archivo installer.conf existe se debera checkear que la instalacion este completa. Si lo esta, se termina. Si no, se muestran los que ya estan definidos y los faltantes.Hay que logear todo 
checkCompleteInstallation() {

	MESSAGE="    TP S07508 Primer Cuatrimestre 2014. Tema C Copyright Grupo 07\n\n"
	NOTINSTALLED="\nComponentes faltantes: "
	NEWPATH=""
	for dir in "${INSTALLERVARIABLES[@]}"
	do
		checkCreated $dir
		if [ $? -eq "0" ]
		then 
			NOTINSTALLED+=$(getVarInfo "$dir")
			NOTINSTALLED+="; "
		else
			NEWPATH=$(changeValue "$dir")
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
	done
	echo -e "$MESSAGE"
	echo -e "$NOTINSTALLED"
	if [ "$NOTINSTALLED" == "\nComponentes faltantes: " ]
	then 
		return 0 #la instalacion estaba completa
	else
		return 1 #la instalacion estaba incompleta
	fi

}
checkCompleteInstallation
