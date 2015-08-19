#!/bin/bash

#
# EXERCISES settings
#
EXERCISES_DIR=Exercises
EXAMPLE_EXERCISE=$1


#
# PARSE
#
FORCE=true

create_dir()
{
    if [ ! -d $1 ]
    then
	mkdir -p $1
    fi
}

empty_c()
{
    RES_DIR=$1
    echo "#include <stdio.h>"          > $RES_DIR/Testing.c
    echo " "                          >> $RES_DIR/Testing.c
    echo "int main() { return 0; } "  >> $RES_DIR/Testing.c
}

empty_java()
{
    RES_DIR=$1
    echo "public class Testing { } " > $RES_DIR/Testing.java
}

check_empty()
{
    CONTENT_COUNT=$(ls -A | grep -v "~" | grep -v Makefile | wc -l)
    if [ $CONTENT_COUNT -ne 0 ] 
    then
	echo "Directory not empty"
	if [ "$FORCE" = "false"  ]
	then
	    echo "Bailing out. Try forced mode (-y) if you want to take a walk on the thin ice"
	    exit 1
	else
	    echo "Forced mode set, continuing"
	fi
    fi
}

create_doc_dir()
{
    create_dir $DOC_DIR
    for i in $DOC_FILES
    do
	echo "Dummy content for '$i'" > $DOC_DIR/$i
    done
}

create_tex_presentation() {
    cp $(dirname $0)/../extra/beamer/example.tex $1
}


create_exercises()
{
    create_dir $EXERCISES_DIR
    create_dir $EXERCISES_DIR/$EXAMPLE_EXERCISE
    echo "Dummy question for '$EXAMPLE_EXERCISE'" > $EXERCISES_DIR/$EXAMPLE_EXERCISE/question.md

    create_dir $EXERCISES_DIR/$EXAMPLE_EXERCISE/src
    empty_java $EXERCISES_DIR/$EXAMPLE_EXERCISE/src
    empty_c    $EXERCISES_DIR/$EXAMPLE_EXERCISE/src


    create_dir $EXERCISES_DIR/$EXAMPLE_EXERCISE/Solutions
    echo "Dummy solution for '$EXAMPLE_EXERCISE'" > $EXERCISES_DIR/$EXAMPLE_EXERCISE/Solutions/solution.md
    
    create_dir $EXERCISES_DIR/$EXAMPLE_EXERCISE/Solutions/src
    empty_java $EXERCISES_DIR/$EXAMPLE_EXERCISE/Solutions/src
    empty_c    $EXERCISES_DIR/$EXAMPLE_EXERCISE/Solutions/src
}


#
#  MAIN
#
if [ "$EXAMPLE_EXERCISE" != "" ]
then
    check_empty
    create_exercises
else
    echo missing exercise name
    exit 1
fi


