#!/bin/bash
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
#IFS=$'\r\n' GLOBIGNORE='*' command eval  'rules=($(cat rules.txt))'
IFS=$'\n' read -d '' -r -a rules < rules.txt

case $key in
    -p|--packagename)
    EXTENSION="$2"
    shift # past argument
    shift # past value
    ;;
esac
done
set -- "${POSITIONAL[@]}"
name=${EXTENSION}
external_path="/data/data/"
external_path+=$name
database_path="$external_path/databases/"

if adb get-state 1>/dev/null 2>&1
then
	echo "Device attached found";
else
	echo "No device found";
	exit 0
fi

if [ -z $key ]
then
	echo "No path supplied, please run with '-p <package name>'"
	exit 0
fi
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
external_folder=`adb shell "su -c 'find $external_path -type f'"`
for file in $external_folder
do
	if [[ $(adb shell "su -c 'strings \"$file\"'" | head -1) == "SQLite format 3" ]];
	then
		for rule in "${rules[@]}"
		do
			#echo "$rule"
			adb shell "su -c 'sqlite3 \"$file\" .dump | grep $rule && echo \"$file\"'"
		done
	fi
done
IFS=$SAVEIFS
#adb shell "su -c 'strings $name'"

