#!/bin/bash 
target='/Volumes/HD-PATU3/Bilder'
backup='/Volumes/Backup+/Bilder'
/usr/bin/killall PTPCamera
year=''
month=''
day=''
dirStructure=''
 
exportDirSammlung=()
cameraType=$1
if [ -z "$1" ]
  then
    echo "No argument supplied"
    echo "camera type is empty"
    exit
fi
if [ -z "cameraType" ]; then
    echo "++++++++++++++"
	echo "no camera type"
	echo "++++++++++++++" 
	exit
fi

createDng() {

	echo 'start create dng'
	if [ "$cameraType" == "canon" ];
	then
		fileEnding="CR2"
	elif [ "$cameraType" == "fuji" ];
	then	
		fileEnding="RAF"
	else 
		echo "++++++++++++++"
		echo "no camera type"
		echo "++++++++++++++" 
		exit
	fi 
	exportDirectory=$(pwd) 
	for dataDir in ${exportDirSammlung[*]}
	do
		echo "create dng files in $$target/$dataDir"
		cd $backup/$dataDir
		find . -iname \*$fileEnding -print0 | parallel -0 \"/Applications/Adobe DNG Converter.app/Contents/MacOS/Adobe DNG Converter\" -d $target/$dataDir
	done
}

createImportDir () {	
	impDirectory=~/$(date +%Y%m%d)
	echo "create import directory $impDirectory"
 	if [ ! -d "$impDirectory" ]; then
  		mkdir -pv "$impDirectory"
  		mkdir -pv "$impDirectory/dng"
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

moveToBackup() {
	echo "backup files: "$backupDir/$value
	cp $value $backupDir
}
 
createImageDirectory() {
	echo $impDirectory/dng
 	idx=0 
	for value in ${importSammlung[*]}
	do
		let ++i
		DATEBITS=( $(exiftool -CreateDate -FileModifyDate -DateTimeOriginal "$value" | awk -F: '{ print $2 ":" $3 ":" $4 ":" $5 ":" $6 }' | sed 's/+[0-9]*//' | sort | grep -v 1970: | cut -d: -f1-6 | tr ':' ' ' | head -1) )
		year=${DATEBITS[0]}
		month=${DATEBITS[1]}
		day=${DATEBITS[2]}	
		echo "split dates in to:" $year/$month/$day
		dirStructure=$year/$month/$day
		directory=$target/$year/$month/$day
		backupDir=$backup/$year/$month/$day		
		 
		if [ ! -d "$directory" ]; then
			echo "create directory: "$directory			 
  			mkdir -pv "$directory"  			 
  			exportDirSammlung[idx]=$dirStructure
  			idx=$((idx+1))
		fi

		if [ ! -d "$backupDir" ]; then
			echo "create back up directory: "$backupDir
  			mkdir -pv "$backupDir"
		fi		 
		moveToBackup $backupDir $value
	done	
	
}
 

createImportDir
createImageDirectory
createDng
deleteImportDir

