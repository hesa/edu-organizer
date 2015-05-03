#!/bin/sh


for dir in $(find Exercises/* -type d -prune | sort -n) ; 
do
    echo "Dir: $dir"
    emacs -nw $dir/question.md $dir/Solutions/solution.md $dir/Solutions/src/*.java

    echo "Press enter to continue..."
    read EINAR
done
