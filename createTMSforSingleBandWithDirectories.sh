#!/bin/bash
#The DuKode Studio 2012
#author ilias koen
#desc: generate single band tms files. 
#ex .createTMSforSingleBands <directory of band tiffs> 
# place tif files on their directories and parce the directories as arguments (where test a directory with the unzipped tif bands)
#ex sh createTMSforSingleBands.sh test test1 


# x to the power of y function  
pow() {
    local x y res i
    x=$1
    y=$2
    res=1
    i=1
    while [ $i -le $y ]; do
        res=$(( res * x ))
        i=$(( i + 1 ))
    done
    echo $res
}

#create tms for the specific band name provided ex. createTMSforBandWithFileName xxxxx_b10.tif
createTMSforBandWithFileName(){
	local BAND
	echo $1
	BAND=$1
	# CHECK IF FILE IS ZIPPED AND IF UNZIP 
	if [[ $BAND == *.gz* ]]; then
		echo "unzipping file:\n $BAND"
		gunzip -d -f $BAND
		echo "done"
		
		#$(echo $BAND10|sed 's/.gz/ /g')
		# BANDZIP=$(echo $BAND )
		BAND=$(echo $BAND|sed 's/.gz//	')
		echo "file is unzipped:\n $BAND"
	fi
	echo $BAND
	if [ -f $BAND ]; then 
		newname=`echo "$BAND"| sed 's/\.TIF$//' | sed 's/\.tif$//'`
		echo "newname = $newname" 
		
		BANDFILE="$newname.alpha.TIF"
		BANDDIR="$newname"
		#echo "$BAND10 exists!"
		# gdalinfo $BAND
		# if [[ "$BAND" == *nn10* ]]; then 
		
		gdalwarp -dstalpha -srcnodata "0 0 0" -dstnodata "0 0 0" -co "TILED=YES" "$BAND" "$BANDFILE"
		# fi
		#gdalinfo $BANDFILE
		#if [ -f "$BAND" ]; then
		# echo "ECHO $BANDFILE"  
		python /Library/Frameworks/GDAL.framework/Versions/1.9/Programs/gdal2tiles.py --srcnodata="0,0,0" -z "$minZoom-$maxZoom" "$BANDFILE" "$BANDDIR"
		#fi 
		# exit 0
		
		# rm "$BAND"
	    rm  "$BANDFILE"
	fi
}

#copy and merge the TMS grey scale files with the newTMS directory name and the specified band combination 
#ex. createTMSLayerWithDirectoriesAndDestinationAndBandCombinations ${args[@]} "754" "754" 
createTMSLayerWithDirectoriesAndDestinationAndBandCombinations()
{ 
	local Directories DestinationDirectory bandCombination
	Directories=("${args[@]}")
	DestinationDirectory=$1
	bandCombination=$2

	echo "Directories = ${args[@]}"
	echo "DestinationDirectory = $DestinationDirectory"
	echo "bandCombination = $bandCombination"
	# exit 0 

	# exit 0 
### go into the directories of the data parced in the original command  
for directory in ${Directories[@]}; do
	if [ -d $directory ]; then 
		
		FILES=$directory/**
		TILEFILESARRAY=(`echo $FILES`)
		# echo "*******\n$FILES\n"
	 	for tiledirectory in ${TILEFILESARRAY[@]}
		do
		echo "forloop "
				if [ -d $tiledirectory ]; then 
					echo "isDirectory  "
					#assign the tms bands directories to the variables. 
					if [[ "$tiledirectory" == *B10* ]]; then 
						echo "tiled directory10 "
						band10=$tiledirectory
					fi	
				
					if [[ "$tiledirectory" == *B20* ]]; then 
						echo "tiled directory20"
						 band20="$tiledirectory"
					fi	
					if [[ "$tiledirectory" == *B30* ]]; then 
						echo "tiled directory30"
						band30="$tiledirectory"
					fi	
					if [[ "$tiledirectory" == *B40* ]]; then 
						echo "tiled directory40"
						band40="$tiledirectory"
					fi
					if [[ "$tiledirectory" == *B50* ]]; then 
						echo "tiled directory50"
						band50="$tiledirectory"
					fi
					if [[ "$tiledirectory" == *B60* ]]; then 
						echo "tiled directory60"
						band60="$tiledirectory"
					fi
					if [[ "$tiledirectory" == *B70* ]]; then 
						echo "tiled director70"
						band70="$tiledirectory"
					fi
				fi
				echo "band combination = $bandCombination"
				#assign bands array withe the directories of the tms bands so they can be located. 
					if [[ "$bandCombination" == "321" ]]; then 
						bands=($band30 $band20 $band10);
					elif [[ "$bandCombination" == "432" ]]; then 
						bands=($band40 $band30 $band20);
					elif [[ $bandCombination == "453" ]]; then 
						bands=($band40 $band50 $band30);
					elif [[ $bandCombination == "543" ]]; then 
						bands=($band50 $band40 $band30);
					elif [[ $bandCombination == "754" ]]; then 
						bands=($band70 $band50 $band40);
					fi
			echo "bands array = ${bands[@]}" 
		done
	 #for band in ${bands[@]}; do
		for (( i=$minZoom; i <=$maxZoom; i++ )); do #ZOOM - LEVEL OF DETAIL  #n 	n>2 × n>2 tiles 	2>2n tiles 
			#n = level of detail source http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#X_and_Y 
			########
			
			# echo "bands is set or not ?: ${bands[1]}/$i"
			if [ -d "${bands[0]}/$i" ]; then 
				 echo "directory $i exists" 
				# echo "*"
				#start tiles rows and columns. 
				 for (( r=0; r <= $(pow 2 $i); r++ )); do 
					# echo "*"
					if [ -d "${bands[0]}/$i/$r" ]; then 
						mkdir $DestinationDirectory/$i/
					fi 
					if [ -d "${bands[0]}/$i/$r" ]; then 
					    # echo "row directory $r exists" 
						# echo "*"
						mkdir $DestinationDirectory
						mkdir $DestinationDirectory/$i/
						mkdir $DestinationDirectory/$i/$r
					fi 

					for (( c=0; c <=$(pow 2 $i); c++ )); do 
						# echo "columns "echo "*"
						if [ -f "${bands[0]}/$i/$r/$c.png" ]; then 	# if file exists on destination merge and composite
							echo "directory $i processing" 
							# echo "column file $c exists" 
							# echo "*"
							if [ -f "$DestinationDirectory/$i/$r/$c.png" ]; then 
								echo "file exists and it is combined *" 
								echo "directory $i processing" 
								convert -monitor -channel RGB -auto-level "${bands[0]}/$i/$r/$c.png" "${bands[1]}/$i/$r/$c.png" "${bands[2]}/$i/$r/$c.png" -set colorspace RGB -combine -set colorspace sRGB -transparent black  "c.png"
								convert c.png "$DestinationDirectory/$i/$r/$c.png" -composite "$DestinationDirectory/$i/$r/$c.png" 
								rm "c.png"

						 	else 	#else copy file to directory
								echo "directory $i does not exist and it is copied"
						 	  	# cp "${bands[0]}/$i/$r/$c.png" "$DestinationDirectory/$i/$r/c.png"
							    convert  -monitor -channel RGB -auto-level "${bands[0]}/$i/$r/$c.png" "${bands[1]}/$i/$r/$c.png" "${bands[2]}/$i/$r/$c.png" -set colorspace RGB -combine -set colorspace sRGB -transparent black "$DestinationDirectory/$i/$r/$c.png"
							fi
						fi
					done 
					#*******
				done 
			fi 
		done
	fi
done


}
#################################################################################

#################################################################################

#################################################################################
args=("$@")
NUM1=$#
NUM2=2

maxZoom=7
minZoom=5

n=-1
 for i in ${args[@]}; do
 	if [ -d $i ]; then 
 	 	echo "["."$(( n += 1 ))"."]" " $i"		
 	fi
 done
 DIRS="$n"
 echo $DIRS

 # echo "hello" 
  ######################################
  for d in ${args[@]}; do
  	echo "$d in arg"
  	if [ -d $d ]; then
  		# echo "$d in directory" 
  		FILES=$d/*
  		TILEFILESARRAY=(`echo $FILES`)
  		# echo "*******\n$FILES\n"
  		# RESULT="found"
  		for i in ${TILEFILESARRAY[@]}; do
  			if [[ "$i" == *B10* ]] || [[  "$i" == *10.tif* ]] ||  [[ "$i" == *01.tif* ]] || [[ "$i" == *nn1.tif* ]] || [[ "$i" == *01.gz* ]]; then
  				createTMSforBandWithFileName $i 
  			
  			# B20
  			elif [[ "$i" == *B20* ]] || [[  "$i" == *20.tif* ]] ||  [[ "$i" == *02.tif* ]] || [[ "$i" == *nn2.tif* ]] || [[ "$i" == *02.gz* ]]; then
  				createTMSforBandWithFileName $i 
  			
  			#B30
  			elif [[ "$i" == *B30* ]] || [[  "$i" == *30.tif* ]] ||  [[ "$i" == *03.tif* ]] || [[ "$i" == *nn3.tif* ]] || [[ "$i" == *03.gz* ]]; then
  				createTMSforBandWithFileName $i 
  			
  			#B40
  			elif [[ "$i" == *B40* ]] || [[  "$i" == *40.tif* ]] ||  [[ "$i" == *04.tif* ]] || [[ "$i" == *nn4.tif* ]] || [[ "$i" == *04.gz* ]]; then
  				createTMSforBandWithFileName $i 
  		
  			
  			#B50
  			elif [[ "$i" == *B50* ]] || [[  "$i" == *50.tif* ]] ||  [[ "$i" == *05.tif* ]] || [[ "$i" == *nn5.tif* ]] || [[ "$i" == *05.gz* ]]; then
  				createTMSforBandWithFileName $i 
  			
  			#B60
  			# elif [[ "$i" == *B60* ]] || [[  "$i" == *60.tif* ]] ||  [[ "$i" == *06.tif* ]] || [[ "$i" == *nn6.gz* ]] || [[ "$i" == *06.gz* ]]; then
  			# 	createTMSforBandWithFileName $i 
  			# 
  			
  			# #B61
  			# 		elif [ "$i" == *B61* ] || [ "$i" == *61.tif* ]; then
  			# 			createTMSforBandWithFileName $i 
  			# 		
  			# 		
  			# 		#B62
  			# 		elif [ "$i" == *B62* ] || [ "$i" == *62.tif* ]; then
  			# 			createTMSforBandWithFileName $i 
  			# 		
  			
  			#B10
  			elif [[ "$i" == *B70* ]] || [[  "$i" == *70.tif* ]] ||  [[ "$i" == *07.tif* ]] || [[ "$i" == *nn7.tif* ]] || [[ "$i" == *07.gz* ]]; then
  				createTMSforBandWithFileName $i 
  					
  			fi
  			
  			#B80
  			# if [[ "$i" == *B80* ]] || [[  "$i" == *80.tif* ]] ||  [[ "$i" == *08.tif* ]] || [[ "$i" == *nn8.gz* ]] || [[ "$i" == *08.gz* ]] ; then
  			# 	createTMSforBandWithFileName $i 
  			# 		
  			# fi
  		done
  	fi
done

  
  echo "#### "
  echo "done"
  exit 0 
