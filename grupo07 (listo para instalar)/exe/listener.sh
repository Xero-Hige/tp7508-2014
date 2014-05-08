#!/usr/bin/env bash

#*****************************************************************************#
#listener.sh								      

#Copyright 2014: Agustin Rojas			<mail>
#		 Bruno Merlo Schurmann		<mail>
#		 Fabrizio Graffe		<mail>
#		 Gaston Alberto Martinez	<gaston.martinez.90@gmail.com>
#		 Leandro Gallipi		<mail>
#		 Luciano Raineri Marchina	<mail>

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program. If not, see <http://www.gnu.org/licenses>
#*****************************************************************************#

sed_escape_filter="s|\([\/\*\?\ ]\)|\\1|g"

log()
{
	message=$(echo "${1}"| sed "$sed_escape_filter")
	type=$(echo "${2}"| sed "$sed_escape_filter")
	./logging.sh "listener" "$message" "$type"
}

Mover()
{
	res=`./move.pl "${1}" "${2}"`
	res="$?"
	if [ ! "$res" == "0" ]
	then	
		log "No movido ${1} a ${2} por $?" "ERR"
	fi
}	

acept_pricelist_file()
{
	file="${1}"
	Mover "$NOVEDIR"/"$file" "$MAEDIR/precios/" #"$file" 
	log "$file - Pricelist aceptado" "INFO"  
	
}

acept_buylist_file()
{
	file="${1}"
	Mover "$NOVEDIR"/"$file" "$ACEPDIR"/  #"$file" 
	log "$file - Buylist aceptado" "INFO"
	
}

reject_file()
{
	file="${1}"
	reject_reason="${2}"
	Mover "$NOVEDIR"/"$file" "$RECHDIR"/ #"$file" 
	log "$file - Rechazado por >>$reject_reason<<" "INFO"
}


is_text_file()
{
	file_output=$(file "${1}")
	file_output=${file_output#*: }
	out_file=` echo "$file_output" | grep "text"` 
	#if [ "$file_output" == "ASCII text, with CRLF line terminators" ] || [ "$file_output" == "ASCII text" ]
	if [ ! -z "$out_file" ] && [ ! "$out_file" == "" ]
	then
		return 0
	else
		return 1
	fi
}

user_exist()
{
	user=${1}
	user_escaped=$(echo "$user"| sed "$sed_escape_filter") 
	
	users=$(grep "^[^;]*;[^;]*;$user_escaped;[0-1];.*\$" "$MAEDIR/asociados.mae")

	if [ "$users" == "" ]
	then
		return 1
	fi

	return 0
}

user_is_colaborator()
{
	user=${1}
	user_escaped=$(echo "$user"| sed "$sed_escape_filter") 
	
	users=$(grep "^[^;]*;[^;]*;$user_escaped;1;.*\$" "$MAEDIR/asociados.mae")

	if [ "$users" == "" ]
	then
		return 1
	fi

	return 0
}

is_valid_exten()
{
	exten=${1}
	exten_remaining=${exten//[^- ]/}
	if [ "$exten_remaining" == "" ]
	then
		return 0
	else
		return 1
	fi
}

is_valid_date()
{
	date=${1}
	year=${date:0:4}
	month=${date:4:2}
	day=${date:6:2}

	is_valid=$(date -d "$year-$month-$day" 2> /dev/null)
	if [ ! "$is_valid" ]
	then
		return 1
	fi
	
	today_in_seconds=$(date +%s)
	date_in_seconds=$(date +%s -d "$year-$month-$day")
	past_limit_in_seconds=$(date +%s -d "2014-01-01")

	if [ "$today_in_seconds" -lt "$date_in_seconds" ] || [ "$past_limit_in_seconds" -gt "$date_in_seconds" ]
	then
		return 1
	fi

	return 0
}

process_buy_list()
{
	file=${1}
	user=${file%%.*}
	exten=${file#*.}

	if [ "$user" == "$file" ] #No hay un "."
	then
		reject_file "$file" "Formato invalido"
		return
	fi

	if ! user_exist "$user"
	then
		reject_file "$file" "User invalido"
		return
	fi

	if ! is_valid_exten "$exten"
	then
		reject_file "$file" "Extesion invalida"
		return
	fi
		
	acept_buylist_file "$file"
}

process_price_list()
{
	file=${1}
	super=${file%%-*}
	aux=${file#*-}
	date=${aux%%.*}
	user=${aux#*.}

	if [ "$super" == "$aux" ] || [ "$date" == "$user" ] #Falta uno de los separadores
	then
		reject_file "$file" "Formato invalido"
		return
	fi

	if ! user_exist "$user"
	then
		reject_file "$file" "User invalido"
		return	
	fi
	
	if ! user_is_colaborator "$user"
	then
		reject_file "$file" "User no es colaborador"
		return
	fi

	if ! is_valid_date "$date"
	then
		reject_file "$file" "Invalid date"
		return
	fi

	acept_pricelist_file "$file"
} 

check_new_files ()
{
	dir_filter=$(echo "$NOVEDIR/" | sed "$sed_escape_filter")
	for file_path in "$NOVEDIR"/*
	do		
		file=${file_path/$dir_filter/}
		if [ ! -f "$file_path" ]
		then
			continue
		fi
	
		if is_text_file "$file_path" 
		then
			if [[ "$file" =~ ^[^-]*-[0-9]{8}\.[^.]*$ ]]
			then 
				process_price_list "$file"
			elif [[ "$file" =~ ^[^.]*\.[^-\ ]*$ ]]
			then
				process_buy_list "$file"
			else
				reject_file "$file" "Formato invalido"			
			fi
		else
			reject_file "$file" "Es de tipo invalido"
		fi

	done
}

invoke_program()
{
	program=${1}	

	pidof_Masterlist=$(pidof Masterlist)
	pidof_Rating=$(pidof Rating)

	if [ "$pidof_Masterlist" != "" ] || [ "$pidof_Rating" != "" ]
	then
		log "Invocacion de $program pospuesta para el siguiente ciclo" "WAR"
		return
	fi

	program_pid=$($program &)
	if [[ ! $program_pid =~ ^[0-9]*\ [0-9]*\$ ]]
	then
		log "Invocacion de $program fallida" "ERR"
		return
	fi

	program_pid=${masterlist_pid#*\ }

	log "$program corriendo bajo el no.: $program_pid" "INFO"
	echo "$program corriendo bajo el no.: $program_pid"
}

check_new_prices_list()
{
	#files=$(ls "$MAEDIR/precios")
	declare local cantidadArchivos=`ls "$MAEDIR/precios" | wc -l`
	#if [ "$files" == "" ] #No Files
	if [ "$cantidadArchivos" -eq "1" ]
	then
		return
	fi 

	#invoke_program "Masterlist"
	./start.sh "Masterlist.sh" "T"
}

check_new_buy_list()
{
	#files=$(ls "$ACEPDIR")
	declare local cantidadArchivos=`ls "$ACEPDIR" | wc -l`
	#if [ "$files" == "" ] #No Files
	if [ "$cantidadArchivos" -eq "1" ]
	then
		return
	fi

	#invoke_program "Rating"
	./start.sh "Rating.sh" "T"
}

#########Program#########

daemon_duration=0 #Ciclos que duro el demonio
sleep_time=2s
run=0


while [ $run -eq 0 ]
do	
	##aumento el contador de ciclos
	daemon_duration=$((daemon_duration + 1))

	#Log
	log "Ciclo Nro $daemon_duration" "INFO"

	#Check files
	check_new_files
	check_new_prices_list
	check_new_buy_list

	sleep "$sleep_time"
done
