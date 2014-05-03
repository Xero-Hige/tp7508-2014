#!/bin/sh
source ../logger/logger.sh
function verificarDuplicado(){
	#echo "verif "$1
	local  find=`find  "$ACEPDIR_PROC" -name $1 -ls| wc -l`
	#echo "resultado find "$find
	return $find
}

function procesarArchivo(){
local dir=$ACEPDIR
dir+="/"
dir+=$1
echo $dir
##OLDIFS=$IFS
##IFS="; "
echo $MAEDIR
##while read id item
 while read  linea   
  do
    id=`echo $linea | sed 's-^\([1-9][0-9]*\);.*\ \+[^\ ]\+\ *$-\1-g'` #nro de item
    descripcion=`echo $linea | sed 's-^[1-9][0-9]*;\(.*\)\ \+[^\ ]\+\ *$-\1-g'` #descripcion
    unidad=`echo $linea | sed 's-^[1-9][0-9]*;.*\ \+\([^\ ]\+\)\ *$-\1-g'` #unidad de medida
    busqueda=`cat $MAEDIR`
    echo $id
    echo $descripcion
    echo $unidad
   for palabra in $descripcion
    do
      busqueda=`echo "$busqueda" | grep -w -i $palabra`
    done
      echo $busqueda


  local noMachea
  #Busca si la unidad coincide con la unidad del producto encontrado
  if [[ `echo $busqueda| grep -w -i $unidad | wc -l` -eq 0 ]]; then
     # Si no es la misma unidad que el producto encontrado, busca su equivalente en la tabla de equivalencias
      if [[ `grep -w -i $unidad $UNIDIR | wc -l` -eq 0 ]]; then
         noMachea=1
      fi
  fi
  if [[ $noMache -eq 1 ]]; then
    #grabo en $INFODIR/pres/arch.xxx
    #N_Item,Producto Pedido
    "$id,$descripcion,$unidad" >> $INFODIR/pres/$archivo
  else
    #N_Item,Producto Pedido,Super_id,Producto_encontrado,Precio
    superId=`echo $busqueda|sed "s/;.*//"`
    #producEncontrado=` echo`
    unidad=`echo "$unidad" | sed '$s/.$//'`
    precio=`echo "$busqueda" | grep -oE '[^;]+$' ` 
    echo "$id,$descripcion,$unidad,$superId,$precio" >> $INFODIR/pres/$archivo
  fi

done < $dir
##IFS=$OLDIFS
}

function moverARechazados(){
	local mover= `mv "$ACEPDIR"/$1 "$RECHDIR" `
	return $mover
}
 
function agregarArchivoProcesado(){
	local mover= `mv "$ACEPDIR"/$1 "$ACEPDIR_PROC" `
	return $mover
}

RECHDIR="/home/agu/Dropbox/Facu/SisOp/tp7508-2014/grupo07/RECH"
ACEPDIR_PROC="/home/agu/Dropbox/Facu/SisOp/tp7508-2014/grupo07/ACEP/proc"
ACEPDIR="/home/agu/Dropbox/Facu/SisOp/tp7508-2014/grupo07/ACEP"
MAEDIR="/home/agu/Dropbox/Facu/SisOp/tp7508-2014/grupo07/MAE/precios.mae"
UNIDIR="/home/agu/Dropbox/Facu/SisOp/tp7508-2014/grupo07/MAE/um.tab"
INFODIR="/home/agu/Dropbox/Facu/SisOp/tp7508-2014/grupo07/INFO"
#Logueos de Inicio de Rating
log $0 "INFO" "Inicio del Rating"
cantListas=`ls -p "$ACEPDIR" | grep -v / | wc -l`
log $0 "INFO" "Cantidad  de Listas de compras a procesar: "$cantListas
archivos=`ls -p "$ACEPDIR" | grep -v / ` 
for archivo in $archivos; do 	
	verificarDuplicado $archivo
	if [ $? -eq 0 ]; then
        log $0 "INFO" "Archivo a procesar: "$archivo
        procesarArchivo $archivo
        #agregarArchivoProcesado $archivo
    else
		log $0 "ERR" "Se rechaza el archivo por duplicado"       	
        #moverARechazados $archivo
	fi
	
	

done 
