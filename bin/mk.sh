#!/bin/sh

#
#  checks/builds every target 
#



#echo variable type
#exit 0
#echo "mk.sh: '$*'"

if [ "$1" = "" ] || [ ! -f $1 ]
then
    echo "Missing file arg or file not found"
    exit 1
fi

FILE=$1
TARG=$2
EXTRA=$3
#echo "FILE: $FILE"

if [ "$TARG" = "" ]
then
    grep -e "[a-Z0-9\-]:" $FILE | grep -v "^#" | awk ' { printf "%s ", $1 }' | sed 's,:,,g' 
    echo ""
elif [ "$EXTRA" = "graph" ]
then
    TMP_FILE=/tmp/$USER/mk.tmp
    if [ "$4" != "nomore" ]
    then
	rm $TMP_FILE
    fi

    FILES=$(find  ./* -prune -name "*.mk" | grep -vE '(uber|most|tmp|meta)' | sed 's,[\n\r], ,g')
#    echo "FILES: $FILES"
    for i in $FILES
    do
	TARGETS=$( grep -w "^$TARG:" $i | sed 's,[/a-Z\.\-]*.mk:,,g' | sed 's,:,,g'  )
#	echo "Searching for '$TARG:' in file: $i => $TARGETS"
	for j in $TARGETS
	do
#	    echo "  ** target: $j"
	    if [ "$TARG" = "$j" ] 
	    then
		echo "$TARG"
	    else
#		echo "$0 $FILE "$j" graph nomore  => "
		$0 $FILE "$j" graph nomore
	    fi
	done
    done  >> $TMP_FILE
#    echo "TMP_FILE: $TMP_FILE"

    if [ "$4" = "" ]
    then
	if [ -s $TMP_FILE ] 
	then
	    for i in $(cat $TMP_FILE | sort -u)
	    do
		#	    echo " --> $i  ==================                                                 "
		grep "^$i:" *.mk | grep -vE '(uber|most|tmp|meta)' | sed 's,[/a-Z\.\-]*.mk:,,g'  
	    done > tmp.mk
	    #	echo done.
	    ./makefile2dot.py < tmp.mk | dot -Tpng -o tmp.png
	    #	echo "NEW FILE: tmp.png"
	    mv tmp.png $TARG.png
	else
	    echo "Can't find target $TARG"
	    exit 1
	fi
    fi
else
    DEP=$(make -f $FILE $TARG 2>&1 | grep -i "Circular" | wc -l)
    if [ $DEP -ne 0 ] ; then 
	echo "Failed: '$TARG' (circular) in '$FILE'";  
	echo "------------------------------------------"
	echo ""
	echo ""
	make -f $FILE $TARG
	echo ""
	echo ""
	exit 1; 
    fi
fi

