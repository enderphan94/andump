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
internal_path="/data/data/"
internal_path+=$name
sdcard_path="/sdcard/Android/data/"
sdcard_path+=$name

if adb get-state 1>/dev/null 2>&1
then
	echo "[+] Device attached found";
	echo
else
	echo "[-] No device found";
	exit 0
fi

if [ -z $key ]
then
	echo "[-] No path supplied, please run with '-p <package name>'"
	exit 0
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
				#echo "$rule"
				adb shell "su -c 'sqlite3 \"$file\" .dump | grep $rule && echo \"$file\" && echo'"
			done
		else
			for rule in "${rules[@]}"
			do
				#echo "$rule"
				adb shell "su -c 'strings \"$file\" | grep $rule && echo \"$file\" \n'"
			done
		fi
	done
	IFS=$SAVEIFS
}

#searching $sdcard_path
searching $internal_path
#adb shell "su -c 'strings $name'"

