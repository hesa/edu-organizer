#!/bin/sh

#
#  checks if lo is present
#

MK=$1
LO_PATHS=$2
if [ "$LO_PATHS=" = "" ] 
then
    echo "$0: Missing args ($*)"
    exit 1
fi

BASE_PATH=$(dirname $0)
LOS=$($BASE_PATH/mk.sh $MK)

RET_VAL=0
MISSING_LOS=""
FOUND_LOS=""
for lo in $LOS
do
#    echo "LO: $lo"
    FOUND=false
    for lo_path in $LO_PATHS
    do
#	echo "  LOPATH: $lo_path"
	if [ -d $lo_path/$lo ] ;
	then
#	    echo " ===================== found $lo in $lo_path"
	    FOUND=true;
	fi
    done
    
    if [ "$FOUND" = "false" ] ;
    then
	MISSING_LOS="$MISSING_LOS $lo"
	RET_VAL=1
    else
	FOUND_LOS="$FOUND_LOS $lo"	
    fi

done

#echo "RETURN: $RET_VAL"
echo "Present Learning objects in '$MK': $FOUND_LOS"
echo "Missing Learning objects in '$MK': $MISSING_LOS"
exit $RET_VAL



