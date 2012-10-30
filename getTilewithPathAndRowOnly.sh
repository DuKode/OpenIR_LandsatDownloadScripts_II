#!/bin/bash
#The DuKode Studio 2012
#author ilias koen
#desc: Download and process a landsat tile by providing path and row. 
#ex .getTilewithPathandRow 010 010 

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
		
			read -p "Press [Enter] key to continue"
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

# 	#################################################################################
# 	#stop here is you only want to download the files 
# 	#################################################################################
# 	read -p "Continue to extract the files (y) Yes (n) N" -n 1 -r
# 	if [[ $REPLY =~ ^[Yy]$ ]]; then
# 		echo "yes"#;#continue
# 	else
# 		exit 0 
# 	fi
# 	#################################################################################
# 	#read downloaded files
# 	#################################################################################
	# $TEMPDIR=$ARCHIVEPATH
	cd $TEMPDIR/
	FILES=*
	TILEFILESARRAY=(`echo $FILES`)
	echo $FILES
	RESULT="found"
	for i in ${TILEFILESARRAY[@]}; do
		if [[ "$i" == *B10* ]] || [[  "$i" == *10.tif* ]] ||  [[ "$i" == *01.tif* ]] || [[ "$i" == *nn1.gz* ]] || [[ "$i" == *01.gz* ]]; then
			BAND10=$i
			#echo "$BAND10 exists!"
		fi
		echo "$BAND10**************************************\n" 
		#B20
		if [[ "$i" == *B20* ]] || [[  "$i" == *20.tif* ]] ||  [[ "$i" == *02.tif* ]] || [[ "$i" == *nn2.gz* ]] || [[ "$i" == *02.gz* ]]; then
			BAND20=$i
			#echo "$BAND20 exists!"
		fi
		#B30
		if [[ "$i" == *B30* ]] || [[  "$i" == *30.tif* ]] ||  [[ "$i" == *03.tif* ]] || [[ "$i" == *nn3.gz* ]] || [[ "$i" == *03.gz* ]]; then
			BAND30=$i
			#echo "$BAND30 exists!"
		fi
		#B40
		if [[ "$i" == *B40* ]] || [[  "$i" == *40.tif* ]] ||  [[ "$i" == *04.tif* ]] || [[ "$i" == *nn4.gz* ]] || [[ "$i" == *04.gz* ]]; then
			BAND40=$i
			#echo "$BAND40 exists!"
		fi
	
		#B50
		if [[ "$i" == *B50* ]] || [[  "$i" == *50.tif* ]] ||  [[ "$i" == *05.tif* ]] || [[ "$i" == *nn5.gz* ]] || [[ "$i" == *05.gz* ]]; then
			BAND50=$i
			#echo "$BAND50 exists!"
		fi
	
		#B60
		if [[ "$i" == *B60* ]] || [[  "$i" == *60.tif* ]] ||  [[ "$i" == *06.tif* ]] || [[ "$i" == *nn6.gz* ]] || [[ "$i" == *06.gz* ]]; then
			BAND60=$i
			#echo "$BAND60 exists!"
		fi
	
		#B61
		if [ "$i" == *B61* ] || [ "$i" == *61.tif* ]; then
			BAND61=$i
			#echo "$BAND61 exists!"
		fi
	
		#B62
		if [ "$i" == *B62* ] || [ "$i" == *62.tif* ]; then
			BAND62=$i
			#echo "$BAND62 exists!"
		fi
	
		#B70
		if [[ "$i" == *B70* ]] || [[  "$i" == *70.tif* ]] ||  [[ "$i" == *07.tif* ]] || [[ "$i" == *nn7.gz* ]] || [[ "$i" == *07.gz* ]]; then
			BAND70=$i
			#echo "$BAND70 exists!"
		fi
	
		#B80
		if [[ "$i" == *B80* ]] || [[  "$i" == *80.tif* ]] ||  [[ "$i" == *08.tif* ]] || [[ "$i" == *nn8.gz* ]] || [[ "$i" == *08.gz* ]] ; then
			BAND80=$i
		#	echo "$BAND80 exists!"
		fi
	done
	echo "#### "
	echo " "
	echo "#################################"
	echo "UNZIPING FILES"
	echo " "
	
	ls 
	
	echo $TEMPDIR/$BAND10
	if [[ -a $BAND10 ]]; then 
	echo "$TEMPDIR/$BAND10" 
	gunzip -d -f $BAND10 
	#$(echo $BAND10|sed 's/.gz/ /g')
	BAND10TIF=$(echo $BAND10|sed 's/.gz/ /g')
	echo $BAND10TIF
	fi 

	if [[ -a $BAND20 ]]; then 
	echo "$TEMPDIR/$BAND20" 
	gunzip -d -f $BAND20 
	#$(echo $BAND10|sed 's/.gz/ /g')
	BAND20TIF=$(echo $BAND20|sed 's/.gz/ /g')
	echo $BAND20TIF
	fi 

	if [[ -a $BAND30 ]]; then 
	echo "$TEMPDIR/$BAND30" 
	gunzip -d -f $BAND30 
	#$(echo $BAND10|sed 's/.gz/ /g')
	BAND30TIF=$(echo $BAND30|sed 's/.gz/ /g')
	echo $BAND30TIF
	fi 

	if [[ -a $BAND40 ]]; then 
	echo "$TEMPDIR/$BAND40" 
	gunzip -d -f $BAND40 
	#$(echo $BAND10|sed 's/.gz/ /g')
	BAND40TIF=$(echo $BAND40|sed 's/.gz/ /g')
	echo $BAND40TIF
	fi 

	if [[ -a $BAND50 ]]; then 
	echo "$TEMPDIR/$BAND50" 
	gunzip -d -f $BAND50 
	#$(echo $BAND10|sed 's/.gz/ /g')
	BAND50TIF=$(echo $BAND50|sed 's/.gz/ /g')
	echo $BAND50TIF
	fi 

	if [[ -a $BAND60 ]]; then 
	echo "$TEMPDIR/$BAND60" 
	gunzip -d -f $BAND60 
	#$(echo $BAND10|sed 's/.gz/ /g')
	BAND60TIF=$(echo $BAND60|sed 's/.gz/ /g')
	echo $BAND60TIF
	fi 

	if [[ -a $BAND61 ]]; then 
	echo "$TEMPDIR/$BAND61" 
	gunzip -d -f $BAND61 
	#$(echo $BAND10|sed 's/.gz/ /g')
	BAND61TIF=$(echo $BAND61|sed 's/.gz/ /g')
	echo $BAND61TIF
	fi 

	if [[ -a $BAND62 ]]; then 
	echo "$TEMPDIR/$BAND62" 
	gunzip -d -f $BAND62
	#$(echo $BAND10|sed 's/.gz/ /g')
	BAND62TIF=$(echo $BAND62|sed 's/.gz/ /g')
	echo $BAND62TIF
	fi 

	if [[ -a $BAND70 ]]; then 
	echo "$TEMPDIR/$BAND70" 
	gunzip -d -f $BAND70 
	#$(echo $BAND10|sed 's/.gz/ /g')
	BAND70TIF=$(echo $BAND70|sed 's/.gz/ /g')
	echo $BAND70TIF
	fi 

	if [[ -a $BAND80 ]]; then 
	echo "$TEMPDIR/$BAND80" 
	gunzip -d -f $BAND80 
	#$(echo $BAND10|sed 's/.gz/ /g')
	BAND80TIF=$(echo $BAND80|sed 's/.gz/ /g')
	echo $BAND80TIF
	fi 
	ls
	#### clean  up unnessasary files 
	rm *.gz 
	rm *.zip 
	rm *.jpeg
	rm *.txt 
# 
# 	#################################################################################
# 	# GENERATE COMPOSITES
# 	#################################################################################
# 	echo "#### "
# 	echo " "
# 	echo "#################################"
# 	echo "GENERATE COMPOSITES"
# 	echo " "
# 
# 	#use for surface reflectance 
# 	#convert ${args[0]} ${args[1]} ${args[2]} -combine -level 0.0%x8% ${args[3]}
# 
# 	## TO DO? 
# 	## add if statement if bands exist. 
# 	## append stuff to log
# 
# 	echo "#################################"
# 	echo "create processing archive"
# 	echo " "
# 	# PROCESSINGDIR="$TILENAME.processing"
# 	# PROCESSEDDIR="$TILENAME.PROCESSEDDIR"
# 
# 
# 	echo "creating temp archive @ $TILENAME.processing"
# 	if [ -d $PROCESSINGDIR ]; then
# 		echo "dir exists ok!"
# 		cd $TEMPDIR/
# 	else
# 		cd ..
# 		mkdir $PROCESSINGDIR
# 		ls
# 	  	# echo "cd $TEMPDIR/"
# 	  	cd $TEMPDIR/
# 	fi
# 
# #echo "create processed archive2"
# #	ls -A .
# #echo "create processed archive3"	
# echo "done"
# echo "#### "
# echo " "
# 	read -p "Process all band combinations(321, 432, 543, 453, 745)? /Yes/ will process all / /No/ I want to select specific bands (y or n) " -n 1 -r
# 	if [[ $REPLY =~ ^[Yy]$ ]]; then
# 
# 
# 		echo "done"
# 
# 		#########################################process all 
# 
# 		#use for GLS2005
# 		convert -monitor $BAND30TIF $BAND20TIF $BAND10TIF -combine $TILENAME".321.TIF"
# 		echo 'from 16 to 8bit'
# 		convert -monitor $TILENAME".321.TIF" -depth 8 $TILENAME".8bit.321.TIF"
# 		rm  $TILENAME".321.TIF"
# 
# 
# 		convert -monitor $BAND40TIF $BAND30TIF $BAND20TIF -combine $TILENAME".432.TIF"
# 		echo 'from 16 to 8bit'
# 		convert -monitor $TILENAME".432.TIF" -depth 8 $TILENAME".8bit.432.TIF"
# 		rm  $TILENAME".432.TIF"
# 		
# 		
# 		
# 		convert -monitor $BAND50TIF $BAND40TIF $BAND30TIF -combine $TILENAME".543.TIF"
# 		echo 'from 16 to 8bit'
# 		convert -monitor $TILENAME".543.TIF" -depth 8 $TILENAME".8bit.543.TIF"
# 		rm $TILENAME".543.TIF"
# 		
# 		
# 		
# 		convert -monitor $BAND40TIF $BAND50TIF $BAND30TIF -combine $TILENAME".453.TIF"
# 		echo 'from 16 to 8bit'
# 		convert -monitor $TILENAME".453.TIF" -depth 8 $TILENAME".8bit.453.TIF"
# 		rm  $TILENAME".453.TIF" 
# 		
# 		
# 		convert -monitor $BAND70TIF $BAND50TIF $BAND40TIF -combine $TILENAME".754.TIF"
# 		echo 'from 16 to 8bit'
# 		convert -monitor $TILENAME".754.TIF" -depth 8 $TILENAME".8bit.754.TIF"
# 		rm $TILENAME".754.TIF" 
# 
# 		echo "done"
# 		echo "#### "
# 		echo " "
# 
# 		# ##########################################
# 		# // apply georeference to composites based on the compiled bands selection// #
# 		##########################################
# 		echo "#################################"
# 		echo "Georeference and Alpha"
# 		echo " "
# 		listgeo $BAND10TIF > $BAND10".txt" 
# 		echo "TILENAME:"."$TILENAME"
# 
# 		#########################################process all
# 
# 		geotifcp -g $BAND10".txt"  $TILENAME".8bit.321.TIF" "$TILENAME.321.TIF"
# 		rm $TILENAME".8bit.321.TIF"
# 		# ############################################
# 		# #generate alpha information for nodata areas.  
# 		# echo ''
# 		gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$TILENAME.321.TIF" "$TILENAME.321.alpha.TIF"
# 
# 
# 		geotifcp -g $BAND10".txt"  $TILENAME".8bit.432.TIF" "$TILENAME.432.TIF"
# 		rm $TILENAME".8bit.432.TIF"
# 		# ############################################
# 		# #generate alpha information for nodata areas.  
# 		# echo ''
# 		gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$TILENAME.432.TIF" "$TILENAME.432.alpha.TIF"
# 		
# 		
# 		geotifcp -g $BAND10".txt"  $TILENAME".8bit.543.TIF" "$TILENAME.543.TIF"
# 		rm $TILENAME".8bit.543.TIF"
# 		# ############################################
# 		# #generate alpha information for nodata areas.  
# 		# echo ''
# 		gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$TILENAME.543.TIF" "$TILENAME.543.alpha.TIF"
# 		
# 		
# 		
# 		geotifcp -g $BAND10".txt"  $TILENAME".8bit.453.TIF" "$TILENAME.453.TIF"
# 		rm $TILENAME".8bit.453.TIF"
# 		# ############################################
# 		# #generate alpha information for nodata areas.  
# 		# echo ''
# 		gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$TILENAME.453.TIF" "$TILENAME.453.alpha.TIF"
# 		
# 		
# 		
# 		geotifcp -g $BAND10".txt"  $TILENAME".8bit.754.TIF" "$TILENAME.754.TIF"
# 		rm $TILENAME".8bit.754.TIF"
# 		# ############################################
# 		# #generate alpha information for nodata areas.  
# 		# echo ''
# 		gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$TILENAME.754.TIF" "$TILENAME.754.alpha.TIF"
# 
# 
# 		### rename files for next step. 
# 		echo "renamingfiles"
# 		cp "$TILENAME.321.alpha.TIF" "321.TIF"
# 		cp "$TILENAME.432.alpha.TIF" "432.TIF"
# 		cp "$TILENAME.543.alpha.TIF" "543.TIF"
# 		cp "$TILENAME.453.alpha.TIF" "453.TIF"
# 		cp "$TILENAME.754.alpha.TIF" "754.TIF"
# 	
# 		echo "done"
# 		echo "#### "
# 		echo "moving files to processed archive"
# 		cd ..
# 		cp "$TEMPDIR/$TILENAME.321.alpha.TIF" "$PROCESSINGDIR/321.TIF"
# 		cp "$TEMPDIR/$TILENAME.432.alpha.TIF" "$PROCESSINGDIR/432.TIF"
# 		cp "$TEMPDIR/$TILENAME.543.alpha.TIF" "$PROCESSINGDIR/543.TIF"
# 		cp "$TEMPDIR/$TILENAME.453.alpha.TIF" "$PROCESSINGDIR/453.TIF"
# 		cp "$TEMPDIR/$TILENAME.754.alpha.TIF" "$PROCESSINGDIR/754.TIF"
# 		mv $PROCESSINGDIR $PROCESSEDDIR
# 		# cd $TEMPDIR
# 		# 	ls
# 		# 	cd ..
# 		# 	ls 
# 		
# 		echo "done"
# 	else
# 		echo "commented out for test"
# 		# ########################################process selection 
# 		# echo ""
# 		# 
# 		# flag321=0
# 		# flag432=0
# 		# flag543=0
# 		# flag453=0
# 		# flag754=0
# 		# 
# 		# read -p "Compile 321 ? (y or n) " -n 1 -r
# 		# if [[ $REPLY =~ ^[Yy]$ ]]; then
# 		# echo ""
# 		# convert -monitor $BAND30TIF $BAND20TIF $BAND10TIF -combine $TILENAME".321.TIF"
# 		# echo 'from 16 to 8bit'
# 		# convert -monitor $TILENAME".321.TIF" -depth 8 $TILENAME".8bit.321.TIF"
# 		# rm  $TILENAME".321.TIF"
# 		# $flag321=1
# 		# fi
# 		# 
# 		# read -p "Compile 432 ? (y or n) " -n 1 -r
# 		# if [[ $REPLY =~ ^[Yy]$ ]]; then
# 		# echo ""
# 		# convert -monitor $BAND40TIF $BAND30TIF $BAND20TIF -combine $TILENAME".432.TIF"
# 		# echo 'from 16 to 8bit'
# 		# convert -monitor $TILENAME".432.TIF" -depth 8 $TILENAME".8bit.432.TIF"
# 		# rm  $TILENAME".432.TIF"
# 		# fi
# 		# 
# 		# read -p "Compile 543 ? (y or n) " -n 1 -r
# 		# if [[ $REPLY =~ ^[Yy]$ ]]; then
# 		# echo ""
# 		# convert -monitor $BAND50TIF $BAND40TIF $BAND30TIF -combine $TILENAME".543.TIF"
# 		# echo 'from 16 to 8bit'
# 		# convert -monitor $TILENAME".543.TIF" -depth 8 $TILENAME".8bit.543.TIF"
# 		# rm $TILENAME".543.TIF"
# 		# $flag543=1
# 		# fi 
# 		# 
# 		# read -p "Compile 453 ? (y or n) " -n 1 -r
# 		# if [[ $REPLY =~ ^[Yy]$ ]]; then
# 		# echo ""
# 		# convert -monitor $BAND40TIF $BAND50TIF $BAND30TIF -combine $TILENAME".453.TIF"
# 		# echo 'from 16 to 8bit'
# 		# convert -monitor $TILENAME".453.TIF" -depth 8 $TILENAME".8bit.453.TIF"
# 		# rm  $TILENAME".453.TIF" 
# 		# $flag453=1
# 		# fi
# 		# 
# 		# read -p "Compile 754 ? (y or n) " -n 1 -r
# 		# if [[ $REPLY =~ ^[Yy]$ ]]; then
# 		# echo ""
# 		# convert -monitor $BAND70TIF $BAND50TIF $BAND40TIF -combine $TILENAME".754.TIF"
# 		# echo 'from 16 to 8bit'
# 		# convert -monitor $TILENAME".754.TIF" -depth 8 $TILENAME".8bit.754.TIF"
# 		# rm $TILENAME".754.TIF" 
# 		# $flag754=1
# 		# fi
# 		# ##########################################
# 		# # // apply georeference to composites based on the compiled bands selection// #
# 		# ##########################################
# 		# listgeo $BAND10TIF > $BAND10".txt" 
# 		# echo "TILENAME:"."$TILENAME"
# 		# 
# 		# #########################################process selection
# 		# if $flag321; then
# 		# geotifcp -g $BAND10".txt"  $TILENAME".8bit.321.TIF" "$TILENAME.321.TIF"
# 		# rm $TILENAME".8bit.321.TIF"
# 		# # ############################################
# 		# # #generate alpha information for nodata areas.  
# 		# gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$TILENAME.321.TIF" "$TILENAME.321.alpha.TIF"
# 		# fi
# 		# 
# 		# if $flag432; then
# 		# geotifcp -g $BAND10".txt"  $TILENAME".8bit.432.TIF" "$TILENAME.432.TIF"
# 		# rm $TILENAME".8bit.432.TIF"
# 		# # ############################################
# 		# # #generate alpha information for nodata areas.  
# 		# gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$TILENAME.432.TIF" "$TILENAME.432.alpha.TIF"
# 		# fi
# 		# 
# 		# if $flag543; then
# 		# geotifcp -g $BAND10".txt"  $TILENAME".8bit.543.TIF" "$TILENAME.543.TIF"
# 		# rm $TILENAME".8bit.543.TIF"
# 		# # ############################################
# 		# # #generate alpha information for nodata areas.  
# 		# gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$TILENAME.543.TIF" "$TILENAME.543.alpha.TIF"
# 		# fi
# 		# 
# 		# if $flag453; then
# 		# geotifcp -g $BAND10".txt"  $TILENAME".8bit.453.TIF" "$TILENAME.453.TIF"
# 		# rm $TILENAME".8bit.453.TIF"
# 		# # ############################################
# 		# # #generate alpha information for nodata areas.  
# 		# gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$TILENAME.453.TIF" "$TILENAME.453.alpha.TIF"
# 		# fi
# 		# 
# 		# if $flag754; then
# 		# geotifcp -g $BAND10".txt"  $TILENAME".8bit.754.TIF" "$TILENAME.754.TIF"
# 		# rm $TILENAME".8bit.754.TIF"
# 		# # ############################################
# 		# # #generate alpha information for nodata areas.  
# 		# gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$TILENAME.754.TIF" "$TILENAME.754.alpha.TIF"
# 		# fi
# 	fi
# fi
# 
# ## rm "321.TIF"
# ## rm "432.TIF"
# ## rm "543.TIF"
# ## rm "453.TIF"
# ## rm "754.TIF"
# # 
# 
# 
# # ############################################
# # 
# # 
# # 
# # 
# # 
# # 
# # #remove 0 0 0 rgb value and replace with transparency.
# # gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" ${args[3]}'GEO.TIF' ${args[3]}'GEO_alpha.TIF'
# # #remove not georeferenced file
# # rm ${args[3]} 
# # rm ${args[0]}'.txt'
# 
# #################################################################################
# # REMOVE FILES
# #################################################################################
# echo "### Removing TMP dir ###" 
# 
# if [ -d  $INDEXDIR ]; then 
# 	echo "directory exists" 
# 	ls -A
# 	echo "cd indexdir"
# 	cd $INDEXDIR 
# 	ls -A
# 	#rm "*"
# 	echo "cd .."
# 	cd .. 
# 	#rm  $INDEXDIR"/*"
# 	#mkdir $INDEXDIR
# 	mv $TEMPDIR/* $INDEXDIR/
# 	#mv $TEMPDIR/"321.TIF" $INDEXDIR
# 	 # mv $TEMPDIR/"432.TIF" $INDEXDIR
# 	 # mv $TEMPDIR/"543.TIF" $INDEXDIR
# 	 # mv $TEMPDIR/"453.TIF" $INDEXDIR
# 	 # mv $TEMPDIR/"754.TIF" $INDEXDIR
# else 
# 	echo "directory does not exist " 
# 	 ls -A
# 	 mkdir $INDEXDIR
# 	 mv $TEMPDIR/"321.TIF" $INDEXDIR
# 	 mv $TEMPDIR/"432.TIF" $INDEXDIR
# 	 mv $TEMPDIR/"543.TIF" $INDEXDIR
# 	 mv $TEMPDIR/"453.TIF" $INDEXDIR
# 	 mv $TEMPDIR/"754.TIF" $INDEXDIR
# fi
# #delete temp directory
# echo "done"
# echo " "
# rm -rf -- $TEMPDIR
# 
# 
# #################################################################################
# # Slice and generate index.html
# #################################################################################
# echo "### Running gdal2tiles_openir.py ###"
# ls -A 
# 
# TIFFILES=($INDEXDIR/*.TIF)
# echo $TIFFILES
# ARRAY=$(IFS=,; echo "[${TIFFILES[*]}]")
# 
# # python gdal2tiles_openir.py ${ARRAY[*]} $INDEXDIR
# 
# #ls -A 
# 
# cd $INDEXDIR
# ls -A
# rm *.TIF
# cd .. 
# #rm $INDEXDIR"/*.TIF"
# 
# echo ###DONE WITH THE PROCESS###
# echo ### Enjoy your maps- OpenIR ###
