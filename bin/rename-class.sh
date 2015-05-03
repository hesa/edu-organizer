#!/bin/sh

OLD=$1
NEW=$2

if [ "$NEW" = "" ]
then
    echo "Missing exercise names"
    exit 1
fi

rename_files() 
{
    EDIR=$1

    for i in $(find $EDIR -type f -name "*.java" 2>/dev/null) 
    do
	NEW_NAME=$(echo $i | sed "s,$OLD,$NEW,g" | xargs basename)
	if [ -f $EDIR/$NEW_NAME ]
	then
	    NEW_NAME=${NEW_NAME}.tmp
	    echo "File $EDIR/$NEW_NAME already exists"
	    echo "Renaming $i to $EDIR/$NEW_NAME"
	fi
	cat $i | sed "s,$OLD,$NEW,g" > $EDIR/$NEW_NAME
	rm  $i
    done
    
}

rename_files src
rename_files Solutions

