
# Pre: -
# Post: Se cargan las variables  para las rutas de archivos
function cargarVariables(){
		config="../conf/installer.conf"
	export CONFIG=$config

	path_confdir=`grep '^CONFDIR' $CONFIG | cut -f2 -d'='`
	export CONFDIR=$path_confdir

	path_acepdir=`grep -s '^ACEPDIR$' $CONFIG | cut -f2 -d'='`
	export ACEPDIR=$path_acepdir

	path_rechdir=`grep '^RECHDIR' $CONFIG | cut -f2 -d'='`
	export RECHDIR=$path_rechdir

	path_maedir=`grep '^MAEDIR' $CONFIG | cut -f2 -d'='`
	export MAEDIR=$path_maedir

	path_logdir=`grep '^LOGDIR' $CONFIG | cut -f2 -d'='`
	export LOGDIR=$path_logdir

	logext=`grep '^LOGEXT' $CONFIG | cut -f2 -d'='`
	export LOGEXT=$logext

	acepdir="$path_acepdir/"
	rechdir="$path_rechdir/"
	maedir="$path_maedir/"
	path_log="Masterlist"	#para no poner ruta de log 2 veces
	path_procdir="$path_maedir/precios/proc/"
	path_preciosdir="$path_maedir/precios/"
	
	superArch="super.mae"
	super="$path_maedir/$superArch"

	asocArch="asociados.mae"
	asoc="$path_maedir/$asocArch"

	preciosArch="precios.mae"
	preciosMae="$path_maedir/$preciosArch"

}

###################################################################################################
###################################################################################################

# Pre: -
# Post: Se inicializa el log del interprete
function iniciarLog(){                  
	declare local cantidadArchivos=`ls $path_preciosdir | wc -l`
	loguear "Inicio de Masterlist "
	loguear "Cantidad de Listas de precios a procesar: $cantidadArchivos"
}

###################################################################################################
###################################################################################################

# Pre: $1 archAcepdir
# Post: Se retorna verdadero si archAcepdir esta duplicado.
function estaArchivoMaedirDuplicado(){
        estaDuplicado=$FALSE
		nombre=`basename "$1"`
        declare local listaProcdir=`ls $path_procdir`  
        for archProcdir in $listaProcdir
        do

			if [ -z "$archProcdir" ] || [ "$archProcdir" == "" ]
			then
				estaDuplicado=$FALSE
				break
			fi


            if [ "$nombre" == "$archProcdir" ]      
            then
                estaDuplicado=$TRUE
				break
            fi
        done
}

###################################################################################################
###################################################################################################

# Pre: $1 archAcepdir duplicado
# Post: Se procesa el registro duplicado de manera que se loguea esta circunstancia y se mueve
# el mismo a la carpeta de rechazados.
function procesarDuplicado(){
	loguearAdvertencia "Se rechaza el archivo por estar DUPLICADO"
	Mover $1 $rechdir
}

###################################################################################################
###################################################################################################

# Pre: $1 archPreciodir 
# Post: Procesa el archivo aceptado.
function validarCabecera() {
	cabeceraValida=$FALSE
	header=$(head -n 1 $1)
	STR="$header"

	campo1=`echo "$header" | cut -d ";" -f1`
	campo2=`echo "$header" | cut -d ";" -f2`
	campo3=`echo "$header" | cut -d ";" -f3`
	campo4=`echo "$header" | cut -d ";" -f4`
	campo5=`echo "$header" | cut -d ";" -f5`
	campo6=`echo "$header" | cut -d ";" -f6`
	declare local usr=`echo "$1" | sed 's/^[^\.]*\.//'`

	email=`grep '^[^;]*\;[^;]*\;'"$usr"';[0-9]\;'"$campo6"'\$' "$asoc"`
	if [ -z "$email" ] || [ "$email" == "" ]
	then
		loguearAdvertencia "Se rechaza el archivo por Correo electrónico del colaborador inválido"
		Mover "$1" "$rechdir"
		cabeceraValida="$FALSE"
		return
	fi

	nombreYsuper=`grep -s '^[0-9]*\;'"$campo2"';'"$campo1"';[^;]*\;[^;]*\;[^;]*\$' "$super"`
	if [ -z "$nombreYsuper" ] || [ "$nombreYsuper" == "" ]
	then
		loguearAdvertencia "Se rechaza el archivo por supermercado inexistente"
		Mover "$1" "$rechdir"
		cabeceraValida="$FALSE"
		return
	fi

	validarCampo3 "$campo3"
	validarCampo4 "$campo4" "$campo3"
	validarCampo5 "$campo5" "$campo3" "$campo4"

	if [ "$Campo3Valido" == $FALSE ] 
	then
		loguearAdvertencia "Se rechaza el archivo por Cantidad de campos invalida"
		Mover "$1" "$rechdir"
		cabeceraValida="$FALSE"
		return
	fi
	if [ "$Campo4Valido" == $FALSE ]
	then
		loguearAdvertencia "Se rechaza el archivo por Posición producto inválida"
		Mover "$1" "$rechdir"
		cabeceraValida="$FALSE"
		return
	fi
	if [ "$Campo5Valido" == $FALSE ]
	then
		loguearAdvertencia "Se rechaza el archivo por Posición precio inválida"
		Mover "$1" "$rechdir"
		cabeceraValida="$FALSE"
		return
	fi

	cabeceraValida="$TRUE"
}

###################################################################################################
###################################################################################################

function validarCampo3() {
	campo3Valido=$TRUE
	if ([[ $1 =~ ^-?[0-9]+$ ]]) && (( $1 > "1" ))
	then
   		campo3Valido=$TRUE
	else
		campo3Valido=$FALSE
	fi
}

###################################################################################################
###################################################################################################

function validarCampo4() {
	campo4Valido=$TRUE
	if ([[ $1 =~ ^-?[0-9]+$ ]]) && (( $1 > "0" )) && (( $1 <= $2 ))
	then
   		campo4Valido=$TRUE
	else
		campo4Valido=$FALSE
	fi
}

###################################################################################################
###################################################################################################

function validarCampo5() {
	campo5Valido=$TRUE
	if ([[ $1 =~ ^-?[0-9]+$ ]]) && (( $1 > "0" )) && (( $1 <= $2 )) && [ ! $1 == $3 ]
	then
   		campo5Valido=$TRUE
	else
		campo5Valido=$FALSE
	fi
}

###################################################################################################
###################################################################################################

function encontrarSuperID() {

	regSuper=`grep '^[^;]*\;'"$2"';'"$1"';[^;]*;[^;]*;[^;]\+$' $super`
    superID=`echo "$regSuper" | cut -s -f1 -d';'`
}

###################################################################################################
###################################################################################################

# Pre: -
# Post: Se finaliza el log del interprete
function finalizarLog() {
	loguear "Fin de Masterlist"
}

###################################################################################################
###################################################################################################


# Pre: $1 Mensaje
# Post: Se loguea mensaje informativo.
function loguear(){
	`"../logger/"./logging.sh "$path_log" "$1" INFO`
}

# Pre: $1 Mensaje
# Post: Se loguea mensaje de error.
function loguearError(){
	`"../logger/"./logging.sh "$path_log" "$1" ERR`
}

# Pre: $1 Mensaje
# Post: Se loguea mensaje de error.
function loguearAdvertencia(){
	`"../logger/"./logging.sh "$path_log" "$1" WAR`
}

###################################################################################################
###################################################################################################

function Mover() {
	"../move/"./move.pl "$1" "$2"
}
###################################################################################################
###################################################################################################

function procesarAltas() {

	registroOk=0
	registroNOk=0
	declare local cantCamposPrecio="$campo3"
	declare local ubicacionProducto="$campo4"
	declare local ubicacionPrecio="$campo5"
	declare local fecha="$4""$5""$6"
	declare local usuarioPrecio="$3"
	declare local supermercado="$2"
	declare local archivo="$1"
	declare local precio
	declare local producto
	
	flag=0

	while read -r linea
	do
		if [ "$flag" -eq 0 ]
		then
			let flag=flag+1
			continue
		fi

		if [ -z linea ]
		then
			continue
		fi

		cantCampos=`echo "$linea" | sed 's/[^;]//g' | wc -m`


		if [ ! "$cantCampos" == "$cantCamposPrecio" ]
		then
			let registroNOk=registroNOk+1
			continue
		fi
		
		precio=`echo "$linea" | cut -d ";" -f"$ubicacionPrecio"`
		producto=`echo "$linea" | cut -d ";" -f"$ubicacionProducto"`
	
		if [ "$producto" == "" ] || [ "$precio" == "" ]
		then
			let registroNOk=registroNOk+1
			continue
		fi

		nuevoReg="$superID"';'"$usuarioPrecio"';'"$fecha"';'"$producto"';'"$precio"
		let registroOk=registroOk+1
		echo "$nuevoReg" >> "$preciosMae"


	done < "$archivo"

	loguear "Registros OK: ""$registroOk"
	loguear "Registros NOK: ""$registroNOk"

}

###################################################################################################
###################################################################################################


function procesarReemplazo() {

	declare local archivo=$1

	registrosEliminados=`grep -c '^'"$2"';'"$3"';'"$4$5$6"';[^;]*\;[0-9]*\.[0-9]*\$' "$preciosMae"`
	`sed -i '/^'"$2"';'"$3"';'"$4$5$6"';[^;]*\;[0-9]*\.[0-9]*\$/d' "$preciosMae"`

	loguear "Registros borrados: $registrosEliminados"
	procesarAltas "$1" "$2" "$3" "$7" "$8" "$9"

}



###################################################################################################
# Sección Principal de Interprete
###################################################################################################

export TRUE=1
export FALSE=0

cantRegInput=0
cantRegOutput=0

# Se cargan las variables  para las rutas de archivos
cargarVariables

# Inicializacion de archivo de log
iniciarLog

# Recorro todos los archivos de MAEDIR para procesarlos
for archp in $path_preciosdir*.*
do    

	if [ "$archp" == "" ] || [ -z "$archp" ]
	then
		break
	fi

	archn=`basename "$archp"`
	archPreciodir="$path_preciosdir$archn"

	if [ "$archPreciodir" == "proc" ]
	then
		continue
	fi

	loguear "Archivo a procesar: $archn"


	#verifico que no sea un archivo duplicado
	estaArchivoMaedirDuplicado "$archPreciodir"
	if [ "$estaDuplicado" == "$TRUE" ]  
	then    
		    procesarDuplicado "$archPreciodir"
	else

		# validar cabecera
		validarCabecera "$archPreciodir"

		if [ "$cabeceraValida" == "$FALSE" ]
		then
			Mover "$archPreciodir" "$rechdir"
			break
		fi

		usuario=`echo "$archPreciodir" | sed 's/^[^\.]*\.//'`
	
		encontrarSuperID "$campo1" "$campo2"

		#revisar la siguiente linea
		reg=`grep -s '^'"$superID"'\;'"$usuario"';[0-9]\{8\};[^;]*\;[0-9]*\.[0-9]*\$' "$preciosMae" | head -n 1`


		# Fecha del nombre del archivo de precios actual
		fechaPrecio=`echo "$archPreciodir" | sed 's/^[^\-]*\-//' | sed 's/\..*\$//'`
		anioPrecio=`echo "$fechaPrecio" | sed 's/[^.]\{4\}\$//'`
		mesPrecio=`echo "$fechaPrecio" | sed 's/[^.]\{4\}//' | sed 's/[^.]\{2\}\$//'`
		diaPrecio=`echo "$fechaPrecio" | sed 's/[^.]\{4\}//' | sed 's/[^.]\{2\}//'`

		
		# No existe el archivo o no existe el registro en el archivo de precios maestro
		if  ([ -z "$reg" ]) || ([ "$reg" == "" ])
		then
			procesarAltas "$archPreciodir" "$superID" "$usuario" "$anioPrecio" "$mesPrecio" "$diaPrecio"
			Mover "$archPreciodir" "$path_procdir"
			continue
			# hacer cosas
		fi

		# Fecha del registro del archivo de precios maestro
		fechaMae=`echo "$reg" | sed 's/^[^;]*\;[^;]*\;//' | sed 's/\([0-9]\{8\}\).*/\1/'`
		anioMae=`echo "$fechaMae" | sed 's/[^.]\{4\}\$//'`
		mesMae=`echo "$fechaMae" | sed 's/[^.]\{4\}//' | sed 's/[^.]\{2\}\$//'`
		diaMae=`echo "$fechaMae" | sed 's/[^.]\{4\}//' | sed 's/[^.]\{2\}//'`


		if [ "$anioPrecio" -gt "$anioMae" ]
		then
			procesarReemplazo "$archPreciodir" "$superID" "$usuario" "$anioMae" "$mesMae" "$diaMae" "$anioPrecio" "$mesPrecio" "$diaPrecio"
		elif [ "$anioPrecio" -eq "$anioMae" ] && [ "$mesPrecio" -gt "$mesMae" ]
		then
			procesarReemplazo "$archPreciodir" "$superID" "$usuario" "$anioMae" "$mesMae" "$diaMae" "$anioPrecio" "$mesPrecio" "$diaPrecio"
		elif [ "$anioPrecio" -eq "$anioMae" ] && [ "$mesPrecio" -eq "$mesMae" ] && [ "$diaPrecio" -gt "$diaMae" ]
		then
			procesarReemplazo "$archPreciodir" "$superID" "$usuario" "$anioMae" "$mesMae" "$diaMae" "$anioPrecio" "$mesPrecio" "$diaPrecio"
		else
			# Rechazo
			Mover "$archPreciodir" "$rechdir"
			loguearAdvertencia "Se rechaza el archivo por fecha anterior a la existente"
		fi


        # muevo el archivo a la carpeta de procesados
        Mover "$archPreciodir" "$path_procdir"

	fi # fin de procesar un archivo

done # fin de procesar todos los archivos

# Finalizacion de archivo de log
finalizarLog

exit 0

