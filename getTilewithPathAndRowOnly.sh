#!/bin/bash
#The DuKode Studio 2012
#author ilias koen
#desc: Download and process a landsat tile by providing path and row. 
#ex .getTilewithPathandRowOnly 010 010 

#################################################################################
args=("$@")
NUM1=$#
NUM2=2
TILEPATH=${args[0]}
TILEROW=${args[1]}
INDEXDIR="p"$TILEPATH"_r"$TILEROW
TEMPDIR="TEMP_"$INDEXDIR
echo "pwd";
if [ $NUM1 -eq $NUM2 ]; then
	echo ""
	echo "You entered Path:"$1" and Row:" $2
	echo ""
else 
	echo ""
	echo "You must enter path and row as arguments only."
	echo ""
	echo "ex. getTimewithPathAndRow 10 10 "
	echo ""
	exit 0 	
fi

#create path for download and select imagery
#path for WRS2 
#ftp://ftp.glcf.umd.edu/glcf/Landsat/WRS2/p010/r010/
TILEDOWNLOADPATH="ftp://ftp.glcf.umd.edu/glcf/Landsat/WRS2/p"$TILEPATH"/r"$TILEROW"/"

echo $TILEDOWNLOADPATH
#################################################################################
#PREPARE LOCAL TEMPORARY FOLDER
#################################################################################
echo "#################################"
echo "PREPARING LOCAL TEMPORARY FOLDER"
#echo " "
if [ -d $TEMPDIR ]; then 
   
	echo "temporary directory already exists! thanks for asking..."
	#################################################################################
	#empty tmp directory before continuing 
	#################################################################################
	#echo $(ls -A $TEMPDIR) #print temp directory files
	if [ "$(ls -A $TEMPDIR)" ]; then

		#commented out the checks for the temp directory - now it just deletes the content here
		# 	    # do dangerous stuff
		# echo " "
		# read -p "Are you sure you want to delete the data from temporary directory? (y or n) " -n 1 -r
		# echo " "
		# if [[ $REPLY =~ ^[Yy]$ ]];then
			echo "Emptying temporary directory...."
			rm $TEMPDIR/*
			echo "Done"
	# 	else
	# 		echo "$TEMPDIR is Empty"
	# 	fi
	# else
	# 	echo "The temporary directory content if any will not be deleted"
	fi

	
else
	mkdir $TEMPDIR
	echo "Created temporary directory for data storage..."
fi

echo "#### "
echo " "
# echo "lookup FTP directory" $TILEDOWNLOADPATH
# read -p "Press [Enter] key to start lookup FTP directory... FTP directory: $TILEDOWNLOADPATH"
#################################################################################

#
wget -rq -nd --no-parent -P $TEMPDIR $TILEDOWNLOADPATH 
#wget -r -nd --no-parent -P $TEMPDIR $TILEDOWNLOADPATH 
cd $TEMPDIR/

FILES=*
#count array
TILEFILESARRAY=(`echo $FILES`)
echo "#################################"
echo "SELECT FILE TO DOWNLOAD\n"
n=-1
for i in ${TILEFILESARRAY[@]}; do
 	echo "["."$(( n += 1 ))"."]" " $i"
 done
TILEFILESARRAYlength="$n"

#check if row and path have corresponding images assosicated to them
if [ $TILEFILESARRAYlength == "0" ]; then 
	echo "Invalid path and row. exit "
	rm -rf -- $TEMPDIR #remove temp directory 
	exit 0 #exit 
fi


echo; echo "Hit a number between 0 - $TILEFILESARRAYlength, then hit return. \n "

selection=
until [ "$selection" = "0" ]; do
	read -n2 keypress -p "hit return to continue." 
	case "$keypress" in
		[0-"$TILEFILESARRAYlength"]* ) 
			echo "Pending statement for the validity of the entry... TO DO"
			SELECTEDINDEX="$keypress"
			echo "\nKEYPRESS = $keypress"
			TILEDOWNLOADPATH="ftp://ftp.glcf.umd.edu/glcf/Landsat/WRS2/p"$TILEPATH"/r"$TILEROW"/${TILEFILESARRAY[SELECTEDINDEX]}/*"
			
			#elaborate on code to check if directory is valid.
			#wget ftp://ftp.glcf.umd.edu/glcf/Landsat/WRS2/p020/r032/p020r032_7dx20010821.ETM-GLS2000/* && echo exists || echo not exist
			#wget --progress=dot $TILEDOWNLOADPATH && echo exist || echo not exist
			break
	 	;;
		* ) echo "Please enter a valid selection"
			echo "$SELECTEDINDEX"
	esac
done
cd .. 

echo "SELECTED FILE ------ ${TILEFILESARRAY[$SELECTEDINDEX]} "
#read -p "Press [Enter] key to download the first file"
#################################################################################


#################################################################################
###### IMAGE SELECTION ????? 
# how are we going to do the selection from the list I am not sure yet. 


#################################################################################
#download data
#################################################################################
echo "#### "
echo " "
echo "#################################"
echo "DOWNLOAD DATA\n"
#echo " "
echo "Downloading tile from path >>>> $TILEDOWNLOADPATH"

TILENAME=${TILEFILESARRAY[$SELECTEDINDEX]}
#ARCHIVEPATH="p$TILEPATH"."r$TILEROW"
ARCHIVEPATH="${TILEFILESARRAY[$SELECTEDINDEX]}"
#download new data - create archive with downloaded data p.r and look for archive if no is selected. 
PROCESSINGDIR="$TILENAME.processing"
PROCESSEDDIR="$TILENAME.PROCESSEDDIR"
#cd ..
#ls -A .
echo "$PROCESSEDDIR"
if [ -d $PROCESSEDDIR ]; then
	echo "finilized archive exists @ $TILENAME.PROCESSEDDIR ok! "
	rm $TEMPDIR/*
 	cp $PROCESSEDDIR/321.TIF $TEMPDIR/
	echo "done"
else
		
	if [ -d $ARCHIVEPATH ]; then 
		rm -f $TEMPDIR/*
		echo "The selected file >>>> $TILENAME data was found in archive! No download necessary...skip that!"
		echo "copying files from $ARCHIVEPATH to $TEMPDIR " 
		cp $ARCHIVEPATH/* $TEMPDIR/
		echo "done"
	else
		read -p "Are you sure you want to download the data? (y or n) " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]; then
		    # do dangerous stuff
			#quiet
			wget -r -nd --no-parent -P $TEMPDIR $TILEDOWNLOADPATH 
		
			echo "\nfinished directory files download"
		
			#clean up temp directory of the link files.
			#clean up temp directory of the link files.
			echo "Clean up temp directory of the temp ftp link files."
			n=-1
			for i in ${TILEFILESARRAY[@]}; do
				echo "deleting temp files"."$(( n += 1 ))"."" " $i"
			 	rm "$TEMPDIR/${TILEFILESARRAY[$n]}"
			done
			echo "Done"
			echo "#### "
			#####
		
			# read -p "Press [Enter] key to continue"
			#CREATE A NEW DIRECTORY WITH AN ARCHIVE OF THE DOWNLOADED FILES.
			echo "#################################"
			echo "ARCHIVE DOWNLOADED DATA\n"
			echo "making directory $ARCHIVEPATH"
			mkdir "$ARCHIVEPATH" 
			echo "copying files from $TEMPDIR to $ARCHIVEPATH" 
			cp $TEMPDIR/* $ARCHIVEPATH/
			
			echo "Done"
			echo "#### "
			echo " "
		else
			echo "\nNo data exist on the archive. exit"
			exit 0
		fi
	fi
fi
	# rm $TEMPDIR/* 
	# rm -rf -- $TEMPDIR
