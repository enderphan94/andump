#!/bin/bash
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

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
path="/data/data/"
path+=$name
echo "$path"
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

true_name=`adb shell "su -c 'find $path -type f'"`
for file in $true_name
do
	echo $file;
done
#adb shell "su -c 'strings $name'"

