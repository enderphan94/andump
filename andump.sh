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
IFS=$'\n' read -d '' -r -a rules < src/rules.txt
IFS=$'\n' read -d '' -r -a vulib < src/vulib.txt

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
    -f|--apk)
    APK="$2"
    shift # past argument
    shift # past value
    ;;
esac
done
set -- "${POSITIONAL[@]}"
name=${PACKAGE}
lib=${LIBRARY}
dir=${DIRECTORY}
apk=${APK}

internal_path="/data/data/"
internal_path+=$name
sdcard_path="/sdcard/Android/data/"
sdcard_path+=$name

current_path=`pwd`
tempapk="$current_path/temp/tempapk"
if [ ! -d "$current_path/temp" ]; then
	mkdir temp
	if [ ! -d $tempapk ]; then
		mkdir $tempapk
	fi
else
	rm temp -rf
	mkdir temp
        if [ ! -d $tempapk ]; then
                mkdir $tempapk
        fi
fi

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

elif [ "$lib" == "true" ] &&  [ ! -z "$apk" ]
then		
	tmp="$current_path/temp"
	cp $apk $tmp
	apk_in_temp=`ls $current_path/temp/*.apk`
	apk_in_temp_count=`ls $current_path/temp/*.apk | wc -l`
	if [ $apk_in_temp_count != 1 ]; then
		echo -e "\e[31m[-]There are something wrong, apk file in temp has more than one or empty\e[97m"
		exit 0
	else
		echo -e "\e[33mIs this the correct apk file $apk_in_temp? yes or no \e[97m"
		read key
		if [ $key = "yes" ]; then
			echo $tmpapk	
			reverse=`apktool d $apk_in_temp -o $tempapk -f`
			#dir="${apk//.apk}"
			#echo $dir
			echo
			echo -e "\e[33mThe files contain unreliable library:\e[97m"
			echo
			for lib in "${vulib[@]}"
			do
				grep -Rw -l "$lib" $tmp
			done	
		else
			exit 0
		fi
	fi
	rm temp -rf
else
	echo -e "\e[31m[-] Please provide correct arguments!!!\e[97m"
	exit 0
fi
