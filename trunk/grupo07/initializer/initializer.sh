#!/bin/bash

#HAY QUE CORRER EL PROGRAMA ASÍ: 'source initializer.sh'



initializeLog()
{
	#Inicializar log
	echo -e "Comando Initializer Inicio de Ejecución\n"
}

initializeListener()
{
	echo -e "Desea efectuar la activación de Listener?\n"
	select ACCION in SI NO
	do
		case $ACCION in
		"SI")
		LISTENER=$(ps aux | grep -c listener.sh) #FIXME usar pgrep
		if [ "$LISTENER" -eq 1 ]
		then
			#HAY PROBLEMAS CUANDO CORRO EL LISTENER			
			echo -e "Se activará el Listener. Para detenerlo, seguir los siguientes pasos.......\n"
			../listener/listener.sh
		else
			echo -e "El demonio Listener ya estaba corriendo\n"
		fi
		break		
		;;
		"NO")
		echo -e "Listener inactivo. Para arrancar el Listener, seguir los siguientes pasos........\n"
		break
		;;
		*)
		echo -e "Elija una de las dos opciones por favor\n"
		;;
		esac
	done
	
}

initializeEnvironment()
{
	if [ "$ENVIRONMENT" = 1 ]
	then
		echo -e "Ambiente ya inicializado. Si quiere reiniciar, termine su sesión e ingrese nuevamente\n"
	else
		echo -e "Se inicializa ambiente\n"
		export ENVIRONMENT=1 #AMBIENTE INICIALIZADO
		export GRUPO="07"
		#CAMBIAR LOS PATH. DECIDIR AL HACER INTEGRACIÓN
		export PATH="."		
		export CONFDIR=$path_confdir
		chmod -R 777 "$CONFDIR"		
		export MAEDIR=$path_maedir
		chmod -R 777 "$MAEDIR"
		export NOVEDIR=$path_novedir
		chmod -R 777 "$NOVEDIR"
		export RECHDIR=$path_rechdir
		chmod -R 777 "$RECHDIR"
		export BINDIR=$path_bindir
		chmod -R 777 "$BINDIR"
		export INFODIR=$path_infodir
		chmod -R 777 "$INFODIR"
		export LOGDIR=$log_dir
		chmod -R 777 "$LOGDIR"
		export LOGEXT=$logext
		export DATASIZE=$datasize
		export LOGSIZE=$logsize
	fi
}

checkCorrectPath()
{
	
	if [ "$#" -eq 1 ]
	then
		echo -e "- Falta $1\n"
		CORRECT_INSTALLATION=0
		#log
	fi
}

checkFileExist()
{
	if [ ! -f $path_maedir/$1 ] #FIXME 
	then	
		CORRECT_INSTALLATION=0
		#Log
	fi
}

checkCorrectInstallation()
{
	config="../conf/installer.conf"
	export CONFIG=$config
	CORRECT_INSTALLATION=1
	path_confdir=$(grep '^CONFDIR' $CONFIG | cut -f2 -d'=')
	checkCorrectPath "$path_confdir" CONFDIR

	path_bindir=$(grep '^BINDIR' $CONFIG | cut -f2 -d'=')
	checkCorrectPath "$path_bindir" BINDIR

	path_acepdir=$(grep -s '^ACEPDIR' $CONFIG | cut -f2 -d'=')
	checkCorrectPath "$path_acepdir" ACEPDIR

	path_rechdir=$(grep '^RECHDIR' $CONFIG | cut -f2 -d'=')
	checkCorrectPath "$path_rechdir" RECHDIR

	path_maedir=$(grep '^MAEDIR' $CONFIG | cut -f2 -d'=')
	checkCorrectPath "$path_maedir" MAEDIR

	path_logdir=$(grep '^LOGDIR' $CONFIG | cut -f2 -d'=')
	checkCorrectPath "$path_logdir" LOGDIR

	logext=$(grep '^LOGEXT' $CONFIG | cut -f2 -d'=')
	checkCorrectPath "$logext" LOGEXT

	logsize=$(grep '^LOGSIZE' $CONFIG | cut -f2 -d'=')
	datasize=$(grep '^DATASIZE' $CONFIG | cut -f2 -d'=')

	if [ "$CORRECT_INSTALLATION" -eq 1 ]
	then
		checkFileExist super.mae
		checkFileExist asociados.mae
		checkFileExist um.tab
	fi
}

showFiles()
{
	for fichero in $(ls $1) #FIXME
	do
		echo -e "$fichero"
	done
}


showContent()
{
	echo -e "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 07\n"
	echo -e "Direct. de Configuración: $CONFDIR"
	showFiles "$CONFDIR"
	echo -e "\nDirectorio Ejecutables: $BINDIR\n"
	showFiles "$BINDIR"	
	echo -e "\nDirect Maestros y Tablas: $MAEDIR\n"
	showFiles "$MAEDIR"	
	echo -e "\nDirectorio de Novedades: $NOVEDIR\n"
	echo -e "Dir. Novedades Aceptadas: $ACEPDIR\n"
	echo -e "Dir. Informes de Salida: $INFODIR\n"
	echo -e "Dir. Archivos Rechazados: $RECHDIR\n"
	echo -e "Data size: $DATASIZE\n"
	echo -e "Dir. de Logs de Comandos: "
	for comando in $(ls $LOGDIR) #FIXME
	do
		echo -e "$LOGDIR/<$comando>.$LOGEXT"
	done
	echo -e "Log size: $LOGSIZE\n"
	echo -e "Estado del Sistema: INICIALIZADO\n"
	echo -e "Listener corriendo bajo el no.: <Process Id de Listener>" #Obtener process ID de Listener
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

#---------------------------------------------------
#PROGRAM

initializeLog
checkCorrectInstallation
if [ "$CORRECT_INSTALLATION" -eq 0 ]
then
	finish
	#exit
	../installer/installer.sh
else
	initializeEnvironment
	initializeListener
	showContent
fi
