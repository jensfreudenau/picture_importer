#!/bin/bash 
target='/Volumes/HD-PATU3/Bilder'
backup='/Volumes/Backup+/Bilder'
cameraType=$1
/usr/bin/killall PTPCamera
importFiles() { 
	find . -type f \( -iname "*.jpg" -o -iname "*.cr2" -o -iname "*.raf"  \) -print0 | while IFS= read -r -d '' file; do	 
		datestring="$(mdls  -raw  -name kMDItemFSCreationDate "$file" | awk '{print $1}' )"	
		splitDates $datestring
		createImageDirectory $backup  
		cp $file $directory
		createImageDirectory $target 
		cp $file $directory	
		echo $directory/$file >> ~/Pictures/importer/$(date +%Y%m%d)_imported.txt		
	done
}

createDng() {	
	if [ "$cameraType" == "canon" ];
	then
		fileEnding="*.CR2"
	elif [ "$cameraType" == "fuji" ];
	then	
		fileEnding="*.RAF"
	else 
		echo "no camera type" 
		exit
	fi 
	exportDir=$directory/dng
	if [ ! -d "$exportDir" ]; then
	  	mkdir -p "$exportDir"
	fi
	open -a "/Applications/Adobe DNG Converter.app/Contents/MacOS/Adobe DNG Converter" --args -d $exportDir $directory/$fileEnding
}

createImportDir () {
	impDirectory=~/$(date +%Y%m%d)
 	if [ ! -d "$impDirectory" ]; then
  		mkdir -p "$impDirectory"
	fi
	cd $impDirectory
   	/usr/local/bin/gphoto2 --get-all-files 
     
}

createImageDirectory() {
	volume=$1 	
	directory=$volume/$year/$month/$day
	if (( ${month##0} > 12 )) || (( ${day##0} > 31 ));
    then
        printf '%s\n' "invalid date: $directory" >&2
        exit
    fi  
	if [ ! -d "$directory" ]; then
  		mkdir -pv "$directory"
	fi
	 
}

splitDates() {
	inputDate=$1
	year=$(awk -F- '{print $1}' <<<$inputDate)	 
	month=$(awk -F- '{print $2}' <<<$inputDate)
	day=$(awk -F- '{print $3}' <<<$inputDate)
}
createImportDir 
importFiles
createDng

