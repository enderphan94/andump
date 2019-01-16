#!/bin/bash
   
echo                                                                                              
echo "                   .___                     "
echo "_____    ____    __| _/_ __  _____ ______   "
echo "\__  \  /    \  / __ |  |  \/     \\____ \  "
echo " / __ \|   |  \/ /_/ |  |  /  Y Y  \  |_> > "
echo "(____  /___|  /\____ |____/|__|_|  /   __/  "
echo "     \/     \/      \/           \/|__|     "
echo "         EnderPhan---------------------     "
echo
echo

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
IFS=$'\n' read -d '' -r -a rules < rules.txt
IFS=$'\n' read -d '' -r -a vulib < vulib.txt

case $key in
    -p|--packagename)
    PACKAGE="$2"
    shift # past argument
    shift # past value
    ;;
    -l|--lib-check)
    LIBRARY="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--directory)
    DIRECTORY="$2"
    shift # past argument
    shift # past value
    ;;
esac
done
set -- "${POSITIONAL[@]}"
name=${PACKAGE}
lib=${LIBRARY}
dir=${DIRECTORY}


internal_path="/data/data/"
internal_path+=$name
sdcard_path="/sdcard/Android/data/"
sdcard_path+=$name


searching () {
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	
	folder=`adb shell "su -c 'find $1 -type f'"`

	for file in $folder
	do
		if [[ $(adb shell "su -c 'strings \"$file\"'" | head -1) == "SQLite format 3" ]];
		then
			for rule in "${rules[@]}"
			do
				adb shell "su -c 'sqlite3 \"$file\" .dump | grep $rule && echo -e \"\e[33m$file\e[97m\" && echo '"
			done
		else
			for rule in "${rules[@]}"
			do
				adb shell "su -c 'strings \"$file\" | grep $rule && echo -e \"\e[33m$file\e[97m\" && echo '"
			done
		fi
	done
	IFS=$SAVEIFS
}

if [ ! -z "$name" ]
then
	if adb get-state 1>/dev/null 2>&1
	then
		echo -e "\e[33m[+] Device attached found\e[97m";
		echo
		searching $internal_path
		searching $sdcard_path
	else
		echo -e "\e[31m[-] No device found. Please run 'adb devices' to find your device and run 'adb connect <your-device>'\e[97m";
		exit 0
	fi

	if [ -z $key ]
	then
		echo -e "\e[31m[-] No path supplied, please run with '-p <package name>'\e[97m"
		exit 0
	fi

elif [ "$lib" == "true" ] && [ ! -z "$dir" ]
	then
	echo -e "\e[33mThe files contain unreliable library:\e[97m"
	echo
	for lib in "${vulib[@]}"
	do
		grep -Rw -l "$lib" $dir
	done
else
	echo -e "\e[31m[-] Please provide correct arguments!!!\e[97m"
	exit 0
fi
