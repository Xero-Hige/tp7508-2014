#!/usr/bin/env bash

log()
{
	message=user_escaped=$(echo "${1}"| sed "$sed_escape_filter")
	type=user_escaped=$(echo "${2}"| sed "$sed_escape_filter")
	./logging.sh "initializer" "$message" "$type" 
}


initializeListener()
{
	echo -e "Desea efectuar la activación de Listener?\n"
	select ACCION in SI NO
	do
		case $ACCION in
		"SI")
		LISTENER=$(pgrep -f listener.sh)
		#if [ "$LISTENER" == "" ]
		#then	
			echo -e "Se activará el listener. Para detenerlo, ejecutar en la terminal:"
			echo -e "./stop.sh listener.sh\n"
			./start.sh "listener.sh" "B"
			sleep 2s
		#else
		#	echo -e "El demonio Listener ya estaba corriendo\n"
		#fi
		break		
		;;
		"NO")
		echo -e "Listener inactivo. Para arrancar el Listener, ejecutar en la terminal:"
		echo -e "./start.sh <nombre_del_proceso_a_inciar_sin_extension>\n"
		break
		;;
		*)
		echo -e "Elija una de las dos opciones por favor\n"
		;;
		esac
	done
	
}

changeModBin()
{
	
	chmod -R +rwx "$BINDIR"
}

changeModRW() {

	chmod -R +rw "$1"
}

initializeEnvironment()
{
	if [ "$ENVIRONMENT" == 1 ]
	then
		echo -e "Ambiente ya inicializado. Si quiere reiniciar, termine su sesión e ingrese nuevamente\n"
		log "Ambiente ya inicializado. Si quiere reiniciar, termine su sesión e ingrese nuevamente\n" "ERR"
	else
		echo -e "Se inicializa ambiente\n"
		PATH=$PATH:.
		export ENVIRONMENT=1 #AMBIENTE INICIALIZADO
		export GRUPO="$grupo"
		#chmod -R 777 "$grupo"
		#NO SE QUE HAY QUE SETEARLE A PATH		
		#export PATH="."		
		export MAEDIR="$grupo/$path_maedir"
		#changeModRW "$MAEDIR"
		export NOVEDIR="$grupo/$path_novedir"
		#changeModRW "$NOVEDIR"
		export ACEPDIR="$grupo/$path_acepdir"
		#changeModRW "$ACEPDIR"
		export RECHDIR="$grupo/$path_rechdir"
		#changeModRW "$RECHDIR"
		export BINDIR="$grupo/$path_bindir"
		#changeModBin
		export INFODIR="$grupo/$path_infodir"
		#changeModRW "$INFODIR"
		export LOGEXT="$logext"
		export DATASIZE="$datasize"
		export LOGSIZE="$logsize"
		export INFON="$grupo/$path_infon"
		#changeModRW "$INFON"
	fi
}

checkCorrectPath()
{	
	if [ "$#" -eq 1 ]
	then
		echo -e "- Falta $1\n"
		CORRECT_INSTALLATION=0
		echo -e "Path incorrecto para $1"
		log "Path incorrecto para $1" "ERR"
	else
		if [ ! -d "$grupo/$1" ]
		then
			CORRECT_INSTALLATION=0
			echo -e "No existe el path $1 que está especificado para $2\n"
			log "No existe el path $1 que está especificado para $2\n" "ERR"
		fi
	fi
}

checkFileExist()
{

	if [ ! -f "$grupo/$path_maedir/$1" ]
	then	
		CORRECT_INSTALLATION=0
		echo -e "No se encuentra el archivo $1 en el directorio $path_maedir"
		log "No se encuentra el archivo $1" "ERR"
	fi
}

findRootPath() 
{
	dirlong=`(pwd)`
	#declare local father=`echo "$dirlong" | sed 's/\/grupo07\/.*\$//'`
	#RUTA="$father""/grupo07/"
	header=$(head -n 1 "initializer.conf")
	RUTA="$header/"
}

checkCorrectLogPath()
{	
	if [ ! -d "$grupo/$path_logdir" ]
	then
		CORRECT_INSTALLATION=0
		echo -e "No existe el path $path_logdir que está especificado para LOGDIR. Se crea un directorio de log auxiliar.\n"
		path_logdir="log"		
		mkdir "$grupo/$path_logdir"
		export LOGDIR="$grupo/$path_logdir"
		log "No existe el path $path_logdir que está especificado para LOGDIR. Se usa este archivo log en su defecto.\n" "ERR"
	fi
}

checkCorrectLogExt()
{	
	if [ "$#" -eq 1 ]
	then
		echo -e "- Falta $1\n"
		CORRECT_INSTALLATION=0
		echo -e "No se ha pasado una $1"
		log "No se ha pasado una $1. Será .log en su defecto" "ERR"
		logext="log"
	fi
}


checkCorrectInstallation()
{
	CONFIG="$CONFDIR/installer.conf"
	CORRECT_INSTALLATION=1

	grupo=`grep '^GRUPO' "$CONFIG" | cut -f2 -d'='`
	
	logext=`grep '^LOGEXT' "$CONFIG" | cut -f2 -d'='`
	checkCorrectPath "$logext" LOGEXT
	export LOGEXT="$logext"

	path_logdir=`grep '^LOGDIR' "$CONFIG" | cut -f2 -d'='`
	checkCorrectLogPath

	export LOGDIR="$grupo/$path_logdir"
	
	user=`grep '^BINDIR' "$CONFIG" | cut -f3 -d'='`

	path_bindir=`grep '^BINDIR' "$CONFIG" | cut -f2 -d'='`
	checkCorrectPath "$path_bindir" BINDIR

	path_acepdir=`grep -s '^ACEPDIR' "$CONFIG" | cut -f2 -d'='`
	checkCorrectPath "$path_acepdir" ACEPDIR

	path_rechdir=`grep '^RECHDIR' "$CONFIG" | cut -f2 -d'='`
	checkCorrectPath "$path_rechdir" RECHDIR

	path_maedir=`grep '^MAEDIR' "$CONFIG" | cut -f2 -d'='`
	checkCorrectPath "$path_maedir" MAEDIR

	path_infodir=`grep '^INFODIR' "$CONFIG" | cut -f2 -d'='`
	checkCorrectPath "$path_infodir" INFODIR

	path_novedir=`grep '^NOVEDIR' "$CONFIG" | cut -f2 -d'='`
	checkCorrectPath "$path_novedir" NOVEDIR

	logsize=`grep '^LOGSIZE' "$CONFIG" | cut -f2 -d'='`
	datasize=`grep '^DATASIZE' "$CONFIG" | cut -f2 -d'='`
	path_infon=`grep '^INFON' "$CONFIG" | cut -f2 -d'='`

	if [ "$CORRECT_INSTALLATION" -eq 1 ]
	then
		chmod -R 777 "$grupo/$path_maedir"
		checkFileExist super.mae
		checkFileExist asociados.mae
		checkFileExist um.tab
	fi
}

showFiles()
{
	for fichero in "$1"/*
	do
		arch=$(echo "$fichero" | sed 's/^.*\///')
		echo -e "$arch"
	done
}


showContent()
{
	echo -e "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 07\n"
	echo -e "PATH: $PATH"
	echo -e "Direct. de Configuración: $path_confdir"
	showFiles "$CONFDIR"
	echo -e "\nDirectorio Ejecutables: $path_bindir"
	showFiles "$BINDIR"	
	echo -e "\nDirect Maestros y Tablas: $path_maedir"
	showFiles "$MAEDIR"	
	echo -e "\nDirectorio de Novedades: $path_novedir"
	echo -e "Dir. Novedades Aceptadas: $path_acepdir"
	echo -e "Dir. Informes de Salida: $path_infodir"
	echo -e "Dir. Archivos Rechazados: $path_rechdir"
	echo -e "Data size: $DATASIZE\n"
	echo -e "Dir. de Logs de Comandos: $path_logdir"
	for comando in "$LOGDIR"/*
	do
		com=$(echo "$comando" | sed 's/^.*\///')
		echo -e "$com.$LOGEXT\n"
	done
	echo -e "Log size: $LOGSIZE\n"
	echo -e "Estado del Sistema: INICIALIZADO\n"

	if [ "$ACCION" == "SI" ]
	then
		PID_LISTENER=`ps -ef | grep "./listener.sh" | grep "bash" | grep -v "grep" | awk '{print $2}'`
		echo -e "Listener corriendo bajo el no.: <$PID_LISTENER>"
	fi
}

finish()
{
	echo -e "\nOprima la tecla 1 cuando considere que entendió los problemas de la instalación para poder cerrar y reiniciar el sistema"
	select ACCION in CERRAR
	do
		case $ACCION in
		"CERRAR")
		break		
		;;
		*)
		echo -e "Oprima la tecla 1 cuando considere que entendió los problemas de la instalación para poder cerrar y reiniciar el sistema\n"
		;;
		esac
	done
}

runInstaller()
{
	PATH_INSTALLER="$RUTA""installer/installer.sh"
	#changeMod "$PATH_INSTALLER"	
	"$PATH_INSTALLER"
}


prueba() {
	./prueba.sh

}


#---------------------------------------------------
#PROGRAM
#Esto es necesario debido a que no se puede parsear la cantidad
#de espacio disponible en el installer si el lenguaje es distinto
#al ingles
export LANG=en_US.UTF-8

findRootPath
export CONFDIR="$RUTA""conf"

echo -e "Comando Initializer Inicio de Ejecución\n"
checkCorrectInstallation
if [ "$CORRECT_INSTALLATION" -eq 0 ]
then
	finish
	runInstaller
else
	initializeEnvironment
	initializeListener
	#prueba
	showContent
fi
