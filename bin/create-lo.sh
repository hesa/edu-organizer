#!/bin/sh


#
# DOC settings
#
DOC_DIR=doc
DOC_FILES="exam.md  goal.md  introduction.md  purpose.md  reading.md  requirements.md"

#
# PRESENTATION settings
#
PRESENTATION_DIR=Presentation
PRESENTATION_SLIDES_DIR=Slides
PRESENTATION_SRC_DIR=src
PRESENTATION_VIDEO_DIR=Video
PRESENTATION_SUBDIRS="$PRESENTATION_SLIDES_DIR $PRESENTATION_SRC_DIR $PRESENTATION_VIDEO_DIR"

#
# EXERCISES settings
#
EXERCISES_DIR=Exercises
EXAMPLE_EXERCISE=Dummy-01


help() {
    echo "$*"
}

usage() {
    help "$0 [OPTIONS]"
    help ""
    help " --help | -h"
    help "    Prints out this message"
    help ""
    help " -y"
    help "    Stops asking question, just do it mode"
    help ""
    help " --all"
    help "    Obsoleted"
    help ""
    help " --lecture-name NAME"
    help "   Creates a lecture called NAME"
    help ""
    help "# --clean"
    help "#   Do NOT create example exercises"
    help ""
    help "Example"
    help "#  $0 --lecture-name C-01"
    help "   Will create a lecture, name C-01, with dummy content"

}

#
# PARSE
#
FORCE=false
LECTURE=
while [ "$1" != "" ]
do
    case "$1" in
	"-h")
	    usage
	    exit 0
	    ;;
	"--help")
	    usage
	    exit 0
	    ;;
	"-y")
	    FORCE=true
	    ;;
	"--all")
	    ALL=true
	    ;;

    	"--lecture-name")
	    LECTURE=$2
	    shift
	    ;;

	*)
	    echo "SYNTAX ERROR.... $1"
	    exit 1
	    ;;
    esac
    shift
done

create_dir()
{
    if [ -d $1 ]
    then
	if [ "$FORCE" = "false"  ]
	then
	    echo "Directory '$1' already exists, and forced mode not set"
	    exit 2
	fi
    fi
    mkdir -p $1
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

create_lecture()
{
    create_dir $PRESENTATION_DIR
    for i in $PRESENTATION_SUBDIRS
    do
	create_dir $PRESENTATION_DIR/$i/
    done

    create_tex_presentation $PRESENTATION_DIR/$PRESENTATION_SLIDES_DIR/$LECTURE.tex

#    create_dir $PRESENTATION_DIR/$PRESENTATION_SRC_DIR/
    empty_java $PRESENTATION_DIR/$PRESENTATION_SRC_DIR/
    empty_c    $PRESENTATION_DIR/$PRESENTATION_SRC_DIR/
    
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

create_makefile_sub()
{
    echo "NAME=$LECTURE"
    echo "CONCEPTS=$LECTURE"
    echo "JAVA_FILES=$PRESENTATION_DIR/$PRESENTATION_SRC_DIR/Testing.java"
    echo "C_FILES=$PRESENTATION_DIR/$PRESENTATION_SRC_DIR/Testing.c"
    echo "PRESENTATION=$PRESENTATION_DIR/$PRESENTATION_SLIDES_DIR/$LECTURE.pdf"
    echo "PRESENTATION_SRC=$PRESENTATION_DIR/$PRESENTATION_SRC_DIR/Testing.java $PRESENTATION_DIR/$PRESENTATION_SRC_DIR/Testing.c"
    echo "VIDEOS="
    echo "EXERCISES=$EXERCISES_DIR/$EXAMPLE_EXERCISE"
    echo "EXERCISES_SRC=$EXERCISES_DIR/$EXAMPLE_EXERCISE/src/Testing.java $EXERCISES_DIR/$EXAMPLE_EXERCISE/src/Testing.c"
    echo "SOLUTIONS_SRC=$EXERCISES_DIR/$EXAMPLE_EXERCISE/Solutions/src/Testing.c $EXERCISES_DIR/$EXAMPLE_EXERCISE/Solutions/src/Testing.java "
    echo "include $(dirname $0)/../makefiles/los.mk"
}


create_makefile()
{
    create_makefile_sub > Makefile
}

check_all()
{
    make -f Makefile
#    make -f Makefile.new dist
 #   make -f Makefile.new solution-dist
}

#
#  MAIN
#
if [ $LECTURE != "" ]
then
    create_dir $LECTURE
    cd $LECTURE
else
    echo "Missing lecture name"
    usage
    exit 1
fi


check_empty

create_doc_dir

create_lecture

create_exercises

create_makefile

#check_all

