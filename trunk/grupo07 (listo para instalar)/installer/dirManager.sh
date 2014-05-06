#
#
#Aca es donde se van a completar la instalacion. Se crean los directorios, se mueven los archivos y se escribe el archivo de configuracion.
#
#


#crea el directorio en el path que se pasa por parametro
createDir() {
	
	PATHRECIEVED="$1"
	FINALPATH=""
	while [ "$FINALPATH" != "$1/" ]
	do
		ACTUALDIR=$(echo "$PATHRECIEVED" | sed "s/^\([^\/]*\).*$/\1/")
		FINALPATH+="$ACTUALDIR/"
		if [ ! -d "$ROOT/$FINALPATH" ]
		then	
			mkdir "$ROOT/$FINALPATH"
		fi
		PATHRECIEVED=$(echo "$PATHRECIEVED" | sed  "s/^[^\/]*\///")
	done
}



#crea los directorios
createDirs() {
	
	echo -e "\nCreando estructuras de directorio\n"
	for dir in "${INSTALLERVARIABLES[@]}"
	do
		DIRPATH="${!dir}"
		if [ "$dir" == "MAEDIR" ]
		then
			echo -e "$DIRPATH\n"
			echo -e "$DIRPATH/precios\n"
			echo -e "$DIRPATH/precios/proc"
			DIRPATH+="/precios/proc"
		elif [ "$dir" == "ACEPDIR" ]
		then
			echo -e "$DIRPATH\n"
			echo -e "$DIRPATH/proc\n"
			DIRPATH+="/proc"
		elif [ "$dir" == "INFODIR" ]
		then
			echo -e "$DIRPATH\n"
			echo -e "$DIRPATH/pres\n"
			DIRPATH+="/pres"
		elif [ "$dir" == "DATASIZE" ] || [ "$dir" == "LOGEXT" ] || [ "$dir" == "LOGSIZE" ]
		then
			continue
		else
			echo -e "$DIRPATH\n"		
		fi
		createDir "$DIRPATH"
	done

}



