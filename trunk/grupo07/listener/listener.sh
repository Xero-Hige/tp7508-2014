#!/bin/bash

#############----------------------------------------------------------------------------------
NOVEDIR="./novedir"
MAEDIR="."
ACEPDIR="./acept"
#############----------------------------------------------------------------------------------

sed_escape_filter="s|\([\/\*\?]\)|\\1|g"

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
		echo "$file: Formato invalido"
		return
	fi

	if ! user_exist "$user"
	then
		echo "$file: User invalido "
		return
	fi

	if ! is_valid_exten "$exten"
	then
		echo "$file: Exten invalido"
		return
	fi
		
	echo "$file: Price list valida "
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
		echo "$file: Formato invalido"
		return
	fi

	if ! user_exist "$user"
	then
		echo "$file: User invalido"
		return	
	fi
	
	if ! user_is_colaborator "$user"
	then
		echo "$file: User no es colaborador"
		return
	fi

	if ! is_valid_date "$date"
	then
		echo "$file: Invalid date"
		return
	fi

	echo "$file: Buy list valida "
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
				echo "$file: Formato invalido"			
			fi
		else
			echo "$file: Es de tipo invalido"
		fi

	done
}

check_new_prices_list()
{
	files=$(ls $MAEDIR/precios)
	if [ "$files" == "" ] #No Files
	then
		return
	fi 

	pidof_Masterlist=$(pidof Masterlist)
	pidof_Rating=$(pidof Rating)

	if [ "$pidof_Masterlist" != "" ] || [ "$pidof_Rating" != "" ]
	then
		echo "Masterlist o Rating corriendo"
		return
	fi

	masterlist_pid=$(Masterlist &)
	if [[ ! $masterlist_pid =~ ^[0-9]*\ [0-9]*\$ ]]
	then
		echo "Error iniciando Masterlist"
		return
	fi

	masterlist_pid=${masterlist_pid#*\ }

	echo "Masterlist corriendo bajo el no.: $masterlist_pid"
}

check_new_buy_list()
{
	files=$(ls $ACEPDIR)
	if [ "$files" == "" ] #No Files
	then
		return
	fi 

	pidof_Masterlist=$(pidof Masterlist)
	pidof_Rating=$(pidof Rating)

	if [ "$pidof_Masterlist" != "" ] || [ "$pidof_Rating" != "" ]
	then
		echo "Masterlist o Rating corriendo"
		return
	fi

	rating_pid=$(Rating &)
	if [[ ! $rating_pid =~ ^[0-9]*\ [0-9]*\$ ]]
	then
		echo "Error iniciando Rating"
		return
	fi

	ratinglist_pid=${rating_pid#*\ }

	echo "Rating corriendo bajo el no.: $ratinglist_pid"
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
