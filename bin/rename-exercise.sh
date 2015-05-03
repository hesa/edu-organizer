#!/bin/sh

EXERCISE=$1
NEW=$2

if [ "$NEW" = "" ]
then
    echo "Missing exercise names"
    exit 1
fi

if [ -d Exercises/$NEW ]
then
    echo Exercise \"$NEW\" already exists...
    exit 2
fi

rename_files() 
{
    EDIR=$1

    for i in $(find $EDIR -type f -name "*.java" 2>/dev/null) 
    do
	NEW_NAME=$(echo $i | sed "s,$EXERCISE,$NEW,g" | xargs basename)
	if [ -f $EDIR/$NEW_NAME ]
	then
	    SAVE_FILE=${NEW_NAME}.tmp
	    echo "File $EDIR/$NEW_NAME already exists"
	    echo "Keeping old orig of $i in $EDIR/$SAVE_FILE"
	    cp $i $EDIR/$SAVE_NAME 
	fi
	cat $i | sed "s,$EXERCISE,$NEW,g" > $EDIR/$NEW_NAME
	rm  $i
    done
    
}

rename_files Exercises/$EXERCISE/src
rename_files Exercises/$EXERCISE/Solutions

mv Exercises/$EXERCISE Exercises/$NEW 
