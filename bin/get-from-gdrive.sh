#!/bin/sh

LO_DIR=~/edu/VCS/LearningObjects
DRIVETOOL=drive
DRIVE_DIR=~/media/google-drive
DRIVE_PATH=edu/Prog-boken

EXPORT_FORMAT=pdf

sync_drive() {

    cd $DRIVE_DIR 2>/dev/null  >/dev/null  
#    rm -fr edu
    drive pull --force --no-prompt --export $EXPORT_FORMAT -ignore-name-clashes --explicitly-export $DRIVE_PATH

    cd -  2>/dev/null >/dev/null  
    
}

handle_file() {
    SOURCE=$(echo $1 |sed -e "s,$DRIVE_PATH,,g")
    FILENAME=$(basename $1)
#    pwd
 #   echo "FILE: $FILENAME"
    DEST_DIR_TMP=$(dirname $1|sed -e 's,[a-zA-Z0-9_-]*exports,,g' -e "s,$DRIVE_PATH,,g")/Presentation/Slides/
  #  echo "DIR: $DEST_DIR_TMP"
    DEST_DIR=$LO_DIR/$DEST_DIR_TMP

    if [ ! -d $DEST_DIR ]
    then
	echo 
	echo 
	echo 
	echo 
	echo "******************************"
	echo "$DEST_DIR not present"
	echo "******************************"
	echo 
	exit 1
    fi
    #    ls -ald $DEST_DIR
    diff   $DRIVE_DIR/$DRIVE_PATH/Learningobjects/$SOURCE \
      $DEST_DIR/$FILENAME 2>&1 >/dev/null
    DIFF_RET=$?
#    echo "$SOURCE: $DIFF_RET"
    echo "cp    $DRIVE_DIR/$DRIVE_PATH/Learningobjects/$SOURCE   $DEST_DIR/$FILENAME"
    cp    $DRIVE_DIR/$DRIVE_PATH/Learningobjects/$SOURCE   $DEST_DIR/$FILENAME
}



handle_files() {
    
    cd $DRIVE_DIR  2>/dev/null >/dev/null

    for i in $(find . -name "*.$EXPORT_FORMAT" | sed -e 's,Learningobjects/,,g' -e 's,\./,,g'  | grep -v -i object | grep -v -i class | grep -v Interface | grep -v main | grep -v Error | grep -v TODO | grep -v message | grep -v Inherita)
    do
	#    echo " * $i *"
	handle_file $i
    done

    cd -  2>/dev/null >/dev/null
}

#
# MAIN
#

sync_drive
handle_files
