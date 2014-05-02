#!/bin/bash

#############----------------------------------------------------------------------------------
NOVEDIR="./novedir"
MAEDIR="."
ACEPDIR="./acept"
RECHDIR="./rech"
#############----------------------------------------------------------------------------------

sed_escape_filter="s|\([\/\*\?\ ]\)|\\1|g"

source ../logger/logger-2.sh

Move()
{
	res=$(../move/move.pl "${1}" "${2}")
	if [ "$res" ]
	then	
		echo "Movido ${1} a ${2}"
	else
		echo "No movido ${1} a ${2} por $?"
	fi
}	

acept_pricelist_file()
{
	file="${1}"
	Move "$NOVEDIR"/"$file" "$MAEDIR"/precios/ #"$file" 
	log "$0" "INFO" "$file - Pricelist aceptado" "Listener"  
	
}

acept_buylist_file()
{
	file="${1}"
	Move "$NOVEDIR"/"$file" "$ACEPDIR"/  #"$file" 
	log "$0" "INFO" "$file - Buylist aceptado" "Listener"
	
}

reject_file()
{
	file="${1}"
	reject_reason="${2}"
	Move "$NOVEDIR"/"$file" "$RECHDIR"/ #"$file" 
	log "$0" "INFO" "$file - Rechazado por >>$reject_reason<<" "Listener"
}


is_text_file()
{
	file_output=$(file "${1}")
	file_output=${file_output#*: }
	if [ "$file_output" == "ASCII text" ]
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
		reject_file "$file" "Exten invalido"
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
	dir_filter=$(echo "$NOVEDIR\/" | sed "$sed_escape_filter")
	for file_path in $NOVEDIR/*
	do
		file=${file_path/$dir_filter/}
		if [ ! -f "$file_path" ]
		then
			continue
		fi
	
		if is_text_file "$file_path" 
		then
			if [[ $file =~ ^[^-]*-[0-9]{8}\.[^.]*$ ]]
			then 
				process_price_list "$file"
			elif [[ $file =~ ^[^.]*\.[^-\ ]*$ ]]
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
		log "$0" "WARN" "Invocacion de $program pospuesta para el siguiente ciclo" "Listener"
		return
	fi

	program_pid=$($program &)
	if [[ ! $program_pid =~ ^[0-9]*\ [0-9]*\$ ]]
	then
		log "$0" "ERRO" "Invocacion de $program fallida" "Listener"
		return
	fi

	program_pid=${masterlist_pid#*\ }

	log "$0" "INFO" "$program corriendo bajo el no.: $program_pid" "Listener"
	echo "$program corriendo bajo el no.: $program_pid"
}

check_new_prices_list()
{
	files=$(ls $MAEDIR/precios)
	if [ "$files" == "" ] #No Files
	then
		return
	fi 

	invoke_program "Masterlist"
}

check_new_buy_list()
{
	files=$(ls $ACEPDIR)
	if [ "$files" == "" ] #No Files
	then
		return
	fi

	invoke_program "Rating"
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
	echo "Ciclo Nro $daemon_duration"

	#Check files
	check_new_files
	check_new_prices_list
	check_new_buy_list

	sleep "$sleep_time"
done
