#!/usr/bin/env bash

CONF_FILE="$CONFDIR/installer.conf" #Hay que poner el que corresponda
TRIM_LOG_SIZE=50

# Receives the name of the env variable to get the value, returns it
getEnvVarValue() {
    VAR_NAME="$1"
    grep "$VAR_NAME" "$CONF_FILE" | sed "s/^[^=]*=\([^=]*\)=.*\$/\1/"
}

# Gets the process calling the logger, returns the correspondant log file
getFilePath() {
    CALLER="$1"
    #LOGDIR=$(getEnvVarValue LOGDIR)
   # LOGEXT=$(getEnvVarValue LOGEXT)
    echo "$LOGDIR/$CALLER.$LOGEXT"
}

# Trims the log file to the last TRIM_LOG_SIZE lines
trimLogFile() {
    FILE="$1"
    AUX_FILE="$1.aux"
    DATE=$(date +"%d/%m/%Y %H:%M:%S")
    echo "$DATE - Log excedido" > "$AUX_FILE"
    tail --lines="$TRIM_LOG_SIZE" "$FILE" >> "$AUX_FILE"
    rm "$FILE"
    mv "$AUX_FILE" "$FILE"
}

# Writes the logging information to the correspondant log file
log () {
    CALLER="$1"
    MSG="$2"
    TYPE="$3"
    FILE=$(getFilePath "$CALLER")
    DATE=$(date +"%d/%m/%Y %H:%M:%S")
    echo -e "$DATE - $USER $CALLER $TYPE:$MSG" >> "$FILE"
    return 0
}


# Obtains the file name and LOGSIZE
FILE=$(getFilePath "$1")

touch "$FILE"
LOGSIZE=$(getEnvVarValue LOGSIZE)
# Checks for trimming
FILE_LINES=$(wc -l < "$FILE")
if [ "$FILE_LINES" -gt "$LOGSIZE" ]
then
    trimLogFile "$FILE"
fi
# Logs
if [ "$#" -lt 2 ] 
then
    echo -e "\nUso: logging comando mensaje [tipo_mensaje]\n\n\tTipo de mensaje puede ser INFO, WAR o ERR.\n\tSi se omite, por defecto es INFO.\n"
    exit -1
elif [ "$#" -eq 2 ]
then
    log "$1" "$2" "INFO"
else
    log "$1" "$2" "$3"
fi
exit 0
