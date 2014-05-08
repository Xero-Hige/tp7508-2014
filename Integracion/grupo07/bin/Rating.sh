#!/usr/bin/env bash
#source ../logger/logger.sh

# Pre: $1 Mensaje
# Post: Se loguea mensaje informativo.
function loguear(){
	./logging.sh "$path_log" "$1" INFO
}

# Pre: $1 Mensaje
# Post: Se loguea mensaje de error.
function loguearError() {
        ./logging.sh "$path_log" "$1" ERR
}

# Pre: $1 Mensaje
# Post: Se loguea mensaje de error.
function loguearAdvertencia() {
        ./logging.sh "$path_log" "$1" WAR
}

function Mover() {
        ./move.pl "$1" "$2"
}

function procesarArchivo() {
local dir=$ACEPDIR
dir+="/"
dir+=$1
 while read  linea   
  do
    id=$(echo $linea | sed 's-^\([1-9][0-9]*\);.*\ \+[^\ ]\+\ *$-\1-g') 
    descripcion=$(echo $linea | sed 's-^[1-9][0-9]*;\(.*\)\ \+[^\ ]\+\ *$-\1-g')
    unidad=$(echo $linea | sed 's-^[1-9][0-9]*;.*\ \+\([^\ ]\+\)\ *$-\1-g')
    busqueda=`cat "$MAEDIR/precios.mae"`
    local noMachea
    for palabra in $descripcion
      do
        busqueda=`echo "$busqueda" | grep -w -i $palabra`
    done
    #echo $busqueda
    if [[ ${#busqueda} -eq 0 ]]; then
      echo "$id,$descripcion $unidad" >> "$INFODIR/pres/$archivo"
      continue      
    fi
    #quito el espacio al final
    unidad=`echo "${unidad%?}"`

  #Busca si la unidad coincide con la unidad del producto encontrado
    if [[ `echo "$busqueda" | grep -w -i "$unidad" | wc -l` -eq 0 ]]; then
       # Si no es la misma unidad que el producto encontrado, busca su equivalente en la tabla de equivalencias
       if [[ `grep -w -i "$unidad $UNIDIR" | wc -l` -eq 0 ]]; then
           noMachea=1
        fi
    fi

    if [[ $noMachea -eq 1 ]]; then
     #grabo en $INFODIR/pres/arch.xxx
     #N_Item,Producto Pedido
      echo "$id,$descripcion $unidad" >> "$INFODIR/pres/$archivo"
    else
      while read -r descrp
        do
          superId=`echo "$descrp"|sed "s/;.*//"`
          producEncontrado=` echo $descrp | cut -d ";" -f4`
          unidad=`echo "$unidad" | sed '$s/.$//'`
          precio=`echo "$descrp" | grep -oE '[^;]+$' ` 
          echo "$id,$descripcion $unidad,$superId,$producEncontrado,$precio" >> "$INFODIR/pres/$archivo"  
      done <<< "$busqueda" 
    fi
done < "$dir"

}

function moverARechazados() {
  Mover "$ACEPDIR/$1" "$RECHDIR/"
}
 
function agregarArchivoProcesado() {
  Mover "$ACEPDIR/$1" "$ACEPDIR_PROC/"
}
function verificarDuplicado() {
  local  find=`find  "$ACEPDIR_PROC" -name $1 -ls| wc -l`
  return "$find"
}


#RECHDIR="/home/agu/Dropbox/Facu/SisOp/tp7508-2014/grupo07/RECH"
ACEPDIR_PROC="$ACEPDIR/proc"
#ACEPDIR="/home/agu/Dropbox/Facu/SisOp/tp7508-2014/grupo07/ACEP"
#MAEDIR="/home/agu/Dropbox/Facu/SisOp/tp7508-2014/grupo07/MAE"
UNIDIR="$MAEDIR/um.tab"
#INFODIR="/home/agu/Dropbox/Facu/SisOp/tp7508-2014/grupo07/INFO"
path_log="Rating"


loguear "Inicio del Rating"
cantListas=`ls -p "$ACEPDIR" | grep -v / | wc -l`
loguear "Cantidad  de Listas de compras a procesar: ""$cantListas"
archivos=`ls -p "$ACEPDIR" | grep -v / ` 
for archivo in $archivos; do    
#echo $archivo

  #valida si el archivo no esta vacio
 if  ! [[ -s "$ACEPDIR"/"$archivo" ]]; then
    loguearError "Se rechaza el archivo  $archivo por estar VACIO"
    moverARechazados "$archivo"
    continue 
  fi

  #verificar Formato del archivo   
  if [[  $(grep -c -v '^[1-9][0-9]*;.*$' "$ACEPDIR"/"$archivo") -ne 0 ]];then
      loguearError "Se rechaza el archivo  $archivo por formato invalido"
      moverARechazados "$archivo"
      continue 
  fi
  verificarDuplicado $archivo
  if [ $? -eq 0 ]; then
        loguear "Archivo a procesar: $archivo" 
        procesarArchivo "$archivo"
        agregarArchivoProcesado "$archivo"
    else

        loguearError "Se rechaza el archivo por duplicado"        
        moverARechazados "$archivo"
  fi
done 

loguear "Fin de Rating"
