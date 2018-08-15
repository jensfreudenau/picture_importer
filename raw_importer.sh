#!/bin/zsh 
target='/Volumes/TT/Bilder'
backup='/Volumes/Backup+/Bilder'
GB64="64GB_SD/DCIM/"
GB32="32GB_SD/DCIM/"
sonySubFolder="100MSDCF"
fujiSubFolder="103_FUJI"

year='-1'
month='-1'
day='-1'
cardDir='-1'
dirStructure='-1'
sdCardFolder='-1'
sourceFolder='-1'
useGphoto=0

exportDirSammlung=()

/usr/bin/killall PTPCamera
cameraType=$1
source=$2


specifyFolderPrefs() {
    if [ "$source" -eq 64 ]; then
        cardDir="/Volumes/$GB64"
    fi

    if [ "$source" -eq 32 ]; then
        cardDir="/Volumes/$GB32"
    fi

    sourceFolder=$cardDir$sdCardFolder
    if [ -z "source" ]; then
        useGphoto=1
    fi

}

specifyCameraPrefs() {

	if [ -z "cameraType" ]; then
	    echo "++++++++++++++"
		echo "no camera type"
		echo "++++++++++++++" 
		exit
	fi
    if [ "$cameraType" = "canon" ];
    then
        sdCardFolder=''
        fileEnding="CR2"
    fi
	if [ "$cameraType" = "fuji" ];
	then	
		sdCardFolder=$fujiSubFolder
		fileEnding="RAF"
	fi		
	if [ "$cameraType" = "sony" ];
	then
		sdCardFolder=$sonySubFolder
		fileEnding="ARW"
	fi

}

createDng() {
	echo 'start create dng'
	for dataDir in ${(u)exportDirSammlung[@]}
	do
		echo "create dng files in "$target"/"$dataDir
		cd $backup/$dataDir
		find . -iname \*$fileEnding -print0 | parallel -0 \"/Applications/Adobe DNG Converter.app/Contents/MacOS/Adobe DNG Converter\" -d $target/$dataDir
	done
}

createImport () {	
	impDirectory=~/$(date +%Y%m%d)
	echo "create import directory $impDirectory"
 	if [ ! -d "$impDirectory" ]; then
  		mkdir -pv "$impDirectory"
	fi
	cd $impDirectory
	if [ "$useGphoto"==0 ]; then
        echo "rsync $sourceFolder/* $impDirectory"
        rsync $sourceFolder/* $impDirectory
    else
        /usr/local/bin/gphoto2 --get-all-files
   	fi

   	importSammlung=(*)

}

deleteImportDir(){
	echo "delete import directory$impDirectory" 
	rm -r $impDirectory
}

moveTo() {
    dir=$1
    file=$2
	echo "backup files: "$impDirectory/$file $dir
	rsync $impDirectory/$file $dir
}
 
createImageDirectory() { 

	for file in ${importSammlung[*]}
	do
		DATEBITS=( $(exiftool -CreateDate -FileModifyDate -DateTimeOriginal "$file" | awk -F: '{ print $2 ":" $3 ":" $4 ":" $5 ":" $6 }' | sed 's/+[0-9]*//' | sort | grep -v 1970: | cut -d: -f1-6 | tr ':' ' ' | head -1) )
		year=${DATEBITS[1]}
		month=${DATEBITS[2]}
		day=${DATEBITS[3]}
		echo "split dates in to:" $year/$month/$day
		dirStructure=$year/$month/$day
		targetDir=$target/$dirStructure
		backupDir=$backup/$dirStructure

        if [ ! -d "$backupDir" ]; then
			echo "create back up directory: "$backupDir
  			mkdir -pv "$backupDir"
		fi
		if [ ! -d "$targetDir" ]; then
			echo "create directory: "$targetDir
  			mkdir -pv "$targetDir"
		fi
		exportDirSammlung+=$dirStructure
		echo '############'

		moveTo $backupDir $file
	done

}

specifyCameraPrefs
specifyFolderPrefs
createImport
createImageDirectory
createDng
deleteImportDir