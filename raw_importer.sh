#!/bin/bash 
target='/Volumes/HD-PATU3/Bilder'
backup='/Volumes/Backup+/Bilder'
/usr/bin/killall PTPCamera
year=''
month=''
day=''
cameraType=$1

if [ -z "cameraType" ]; then
    echo "camera type is empty"
    exit
fi

createDng() {
	
	if [ "$cameraType" == "canon" ];
	then
		fileEnding="*.CR2"
	elif [ "$cameraType" == "fuji" ];
	then	
		fileEnding="*.RAF"
	else 
		echo "++++++++++++++"
		echo "no camera type"
		echo "++++++++++++++" 
		exit
	fi 
	
	for val in ${exportDirSammlung[*]}
	do 
		cd $val
		directory=$(pwd) 
		echo "create dng files in $val/dng from $directory/$fileEnding"	
		open -a "/Applications/Adobe DNG Converter.app/Contents/MacOS/Adobe DNG Converter" --args -d $exportDir $directory/$fileEnding
	done	 
}

createImportDir () {	
	impDirectory=~/$(date +%Y%m%d)
	echo "create import directory $impDirectory"
 	if [ ! -d "$impDirectory" ]; then
  		mkdir -pv "$impDirectory"
	fi
	cd $impDirectory
   	/usr/local/bin/gphoto2 --get-all-files 
   	shopt -s nullglob   
   	importSammlung=(*)
    shopt -u nullglob      
}

deleteImportDir(){
	echo "delete import directory$impDirectory" 
	rm -r $impDirectory
}

createImageDirectory() {
	for value in ${importSammlung[*]}
	do
		DATEBITS=( $(exiftool -CreateDate -FileModifyDate -DateTimeOriginal "$value" | awk -F: '{ print $2 ":" $3 ":" $4 ":" $5 ":" $6 }' | sed 's/+[0-9]*//' | sort | grep -v 1970: | cut -d: -f1-6 | tr ':' ' ' | head -1) )
		year=${DATEBITS[0]}
		month=${DATEBITS[1]}
		day=${DATEBITS[2]}	
		echo "split dates in to:" $year/$month/$day
		directory=$target/$year/$month/$day
		exportDirSammlung=($directory)
		exportDir=$directory/dng
		
		if [ ! -d "$directory" ]; then
  			mkdir -pv "$directory"
  			mkdir -pv "$exportDir"
		fi
		cp $value $directory	
		
	done	
}
 

createImportDir 
createImageDirectory
createDng
deleteImportDir

