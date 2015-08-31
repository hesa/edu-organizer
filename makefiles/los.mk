EDUO_PATH=/home/hesa/opt/edu-organizer/

EDUO_BIN_PATH=${EDUO_PATH}/bin

include ${EDUO_PATH}/makefiles/settings.mk

LOG_FILE=/tmp/edu-organiser-$(USER).log

COMPILEFILE=${EDUO_BIN_PATH}/compilefile
COPYFILES_CODED=${EDUO_BIN_PATH}/copyfiles-coded
COPYFILES=${EDUO_BIN_PATH}/copyfiles
INDENT=astyle

DIR=$(shell pwd | xargs basename)
export LO_NAME=$(LO_CNT)$(shell grep NAME Makefile | sed 's/NAME=//g')
export LO_NAME_DIR=$(LO_CNT)$(shell grep NAME Makefile | sed -e 's/NAME=//g' -e 's/ /\-/g' )
DATE=$(shell date '+%Y-%m-%d-%H%M%S')

NAME=$(shell pwd | xargs basename)
ifeq (${DIST_DIR},)
DIST_DIR=$(DIST_DIR_BASE)/LearningObjects/$(LO_NAME_DIR)
endif

LO_DIST_DIR=$(DIST_DIR)/$(LEC_NAME)/$(LO_NAME_DIR)/

MY_TEXINPUTS:=$(TEXINPUTS):${EDUO_PATH}/extra/beamer:.

ZIP_FILE=$(DIR)-$(DATE).zip
SOL_ZIP_FILE=$(DIR)-solutions-$(DATE).zip

OVERVIEW_MD_SRC=doc/goal.md  doc/introduction.md  doc/purpose.md  doc/requirements.md doc/reading.md doc/exam.md



#export EXERCISES
EXERCISES_MD=gen/exercises.md
SOLUTIONS_MD=gen/solutions.md
OVERVIEW_MD=gen/overview.md 
EXAM_MD=gen/exam.md 
#ifeq ($(DIST_DIR), "")
#export DIST_DIR="."
#endif
ALL_MD=$(OVERVIEW_MD) $(EXERCISES_MD)
# $(SOLUTIONS_MD)

EXERCISES_PDF=$(EXERCISES_MD:.md=.pdf)
SOLUTIONS_PDF=$(SOLUTIONS_MD:.md=.pdf)
#EXERCISES_PDF=$(EXERCISES_MD:.md=.pdf)
#SOLUTIONS_PDF=$(SOLUTIONS_MD:.md=.pdf)
OVERVIEW_PDF=$(OVERVIEW_MD:.md=.pdf)
EXAM_PDF=$(EXAM_MD:.md=.pdf)

ALL_PDF := $(ALL_MD:.md=.pdf)
#SOLUTIONS_PDF := $(SOLUTIONS_MD:.md=.pdf)

ALL_FILES=$(EXAM_MD_SRC) $(OVERVIEW_MD_SRC) $(PRESENTATION) $(EXERCISES) $(EXERCISES_SRC) $(SOLUTIONS_SRC) $(JAVA_FILES) $(C_FILES) 

IGNORE_EXERCISES=.ignore-exercises

.ignore-exercises:
	@if [ "$(EXERCISES)" = "$(IGNORE_EXERCISES)" ] ; then  \
		echo "Creating $(IGNORE_EXERCISES)" ; touch $(IGNORE_EXERCISES) ; fi	

check: $(ALL_FILES) check-exercises check-presentation check-docs
	@if [ "$(VIDEOS)" = "" ] ;  then  echo " * Missing videos * " ;  fi
	@echo "Everything seems ok, $(DATE)  :)"

check-docs:
	@for file in introduction.md reading.md ; do \
		echo "   * $$file :" ; \
		test -f doc/$$file  ; \
		echo -n "     * Dummy content: " ; \
		if [ `grep -c "^Dummy" doc/$$file` != "0" ]  ; then exit 1 ; fi ; \
		echo "OK" ; \
		echo -n "     * Empty:         " ; \
		if [ `wc -w doc/$$file | grep -c "^0"` != "0" ]  ; then exit 1 ; fi ; \
		echo OK ;\
	done


deep-check: 
		@echo -n " * make:   "  && make  >$(LOG_FILE) 2>&1 && echo " OK" 
		@echo -n " * check:  "  && make check >$(LOG_FILE) 2>&1 && echo " OK" 

deepest-check: deep-check
		@echo -n " * distribution:"  && make dist             >$(LOG_FILE) 2>&1 && echo  " OK" 
		@echo -n " * solution-dist:" && make solution-dist    >$(LOG_FILE) 2>&1 && echo " OK" 

#instruktioner.pdf: instruktioner.md
#	pandoc $< -o $@


all: dist solution-dist


purpose:
	@cat doc/purpose.md

introduction:
	@cat doc/introduction.md

goal:
	@cat doc/goal.md

display-presentation: check $(PRESENTATION)
	evince $(PRESENTATION)

display-exercises: check $(EXERCISES) $(SOLUTIONS) exercises solutions 
	@echo "Exercises for $(DIR)" 
	evince gen/exercises.pdf && evince gen/solutions.pdf || exit 1
#	for dir in $(EXERCISES) ; do \
#		evince gen/exercises.pdf && evince gen/solutions.pdf || exit 1 ; \
#	done ; 

###

length:
	@../video-length $(VIDEOS)

cleancrap:
	@echo "Cleaning up emacs save files"
	@find . -name "*~" | xargs rm -f

prepare:
	rm    -fr tmp/$(DIR)
	mkdir -p  tmp/$(DIR)
	mkdir -p  tmp/$(DIR)/Presentation/src
	mkdir -p  tmp/$(DIR)/Presentation/Slides
	mkdir -p  tmp/$(DIR)/Presentation/Video
	mkdir -p  tmp/$(DIR)/Exercises

prepare-solution:
	rm    -fr tmp/$(DIR)
	mkdir -p  tmp/$(DIR)
	mkdir -p  tmp/$(DIR)/Exercises/

solutions: exercises
	if [ "$(EXERCISES)" != ".ignore-exercises" ] ; then  \
		make $(SOLUTIONS_PDF) ;\
	fi
	if [ "$(SOLUTIONS_SRC)" != "" ] ; then \
		echo "Copying solution sources: " ; \
		$(COPYFILES_CODED) "$(SOLUTIONS_SRC)" tmp/$(DIR)/$$dir/ ; \
	fi ; \

exercises: 
	make $(EXERCISES_PDF)
	@if [ "$(EXERCISES_EXTRA)" != "" ] ; then \
		echo "Copying exercise extra files: " ; \
		$(COPYFILES_CODED) "$(EXERCISES_EXTRA)" tmp/$(DIR)/$$dir/ ; \
	fi
	@if [ "$(EXERCISES_SRC)" != "" ] ; then \
		echo "Copying exercise source code: " ; \
		$(COPYFILES_CODED) "$(EXERCISES_SRC)" tmp/$(DIR)/$$dir/ ; \
	fi

#$(EXERCISES_PDF)

$(SOLUTIONS_MD):
	@if [ "$(EXERCISES)" = "" ] ; then \
		echo " * " ;  \
		echo " * " ;  \
		echo " * ERROR Missing exercises *" ;  \
		echo " * " ;  \
		echo " * " ;  \
		echo " * " ;  \
		exit 1;       \
	elif [ "$(EXERCISES)" = ".ignore-exercises" ] ; then  \
		: ;\
	else  \
		echo "SOLUTIONS_MD" ;\
		if [ ! -d gen ] ; then mkdir gen ; fi ; \
	  echo "# Solutions for $(DIR)" > $(SOLUTIONS_MD) ;\
	  echo "" >> $(SOLUTIONS_MD) ;\
	  for dir in $(EXERCISES) ; do \
		SHORTNAME=`basename "$$dir" ` ; \
		if [ ! -s  $$dir/Solutions/solution.md ] ; then echo "Missing solution for: $$dir "; exit 1 ; \
		else \
			echo "## $$SHORTNAME" >> $(SOLUTIONS_MD) && \
			cat $$dir/Solutions/solution.md >> $(SOLUTIONS_MD) && \
			echo "" >> $(SOLUTIONS_MD) && \
			echo "" >> $(SOLUTIONS_MD) ; \
		fi ; \
	  done ; \
	fi

all-exercises: $(EXERCISES_MD)
	cat $(EXERCISES_MD) >> $(EXERC)

all-solutions: $(SOLUTIONS_MD)
	if [ "$(EXERCISES)" != ".ignore-exercises" ] ; then  \
		cat $(SOLUTIONS_MD) >> $(SOLS) ;\
	fi	

$(EXERCISES_MD):
	if [ ! -d gen ] ; then mkdir gen ; fi
	@echo "# Exercises for $(LO_NAME)" > $(EXERCISES_MD)
	@echo "" >> $(EXERCISES_MD)

	@if [ "$(EXERCISES)" = ".ignore-exercises" ] ; then echo "No exercises"  >> $(EXERCISES_MD) ; else \
	for dir in $(EXERCISES) ; do \
		SHORTNAME=`basename "$$dir" ` ; \
		if [ ! -s  $$dir/question.md ] ; then echo "Missing Exercise for: $$dir "; exit 1 ; \
		else \
			echo "## $$SHORTNAME  " >> $(EXERCISES_MD)  && \
			cat $$dir/question.md >> $(EXERCISES_MD); \
			echo "" >> $(EXERCISES_MD); \
		fi ; \
		if [ ! -s  $$dir/Solutions/solution.md ] ; then echo "Missing solution for: $$dir "; exit 1 ; fi \
	done ; \
	fi

$(EXERCISES_MD): $(EXERCISES) 

check-presentation:$(PRESENTATION)
	@echo "Checking presentation source code"
	@for file in $(PRESENTATION_SRC) ; do \
		pwd && echo -n  "  $$file: " && $(COMPILEFILE)  $$file && \
		echo "OK" || exit 1 ; \
        done
	@echo "Checking video files"
	if [ "$(VIDEOS)" != "" ] ; \
	   then \
	   for vid in $(VIDEOS) ; \
		do \
		  test -f $(VIDEO_PATH)/$$vid || exit 1; \
	   done ;\
        fi
# 		  test -f "$(VIDEO_PATH)/$$VIDEO_MD_DIR/content.md" && \


presentation: check-presentation 
	mkdir -p     tmp/$(DIR)/Presentation/Slides
	@if [ "$(VIDEOS)" != "" ] ; \
	   then \
	   mkdir -p     tmp/$(DIR)/Presentation/Video/ ; \
	   chmod +rw    tmp/$(DIR)/Presentation/Video/* ; \
	   for vid in $(VIDEOS) ; \
		do \
		  echo cp "$(VIDEO_PATH)/$$vid" tmp/$(DIR)/Presentation/Video/ || exit 1; \
		  cp "$(VIDEO_PATH)/$$vid" tmp/$(DIR)/Presentation/Video/ || exit 1; \
	   done ;\
        fi
	if [ "$(PRESENTATION)" != "" ] ; \
	   then cp $(PRESENTATION) tmp/$(DIR)/Presentation/Slides; \
	else exit 1 ; \
	fi
	if [ "$(PRESENTATION_SRC)" != "" ] ; \
	   then $(COPYFILES_CODED) "$(PRESENTATION_SRC)" tmp/$(DIR)/; \
	fi

overview: $(OVERVIEW_PDF) Makefile

$(OVERVIEW_MD): $(OVERVIEW_MD_SRC)
	@for file in $(OVERVIEW_MD_SRC) ; do \
		echo "Check $$file"; if [ ! -s $$file  ] ; then exit 1; fi ; echo "$$file ok" ; \
	done

#	echo "DIR: $(LO_NAME)"

	if [ ! -d gen ] ; then mkdir gen ; fi
#	if [ ! -s $(OVERVIEW_MD) ] ; then exit 1; fi
	echo "#$(LO_NAME)" > $(OVERVIEW_MD)
	echo "" >> $(OVERVIEW_MD)

	echo "##Introduction " >> $(OVERVIEW_MD)
	cat doc/introduction.md >> $(OVERVIEW_MD)

	echo "" >> $(OVERVIEW_MD)
	echo "##Purpose " >> $(OVERVIEW_MD)
	cat doc/purpose.md >> $(OVERVIEW_MD)

	echo "" >> $(OVERVIEW_MD)
	echo "##Requirements" >> $(OVERVIEW_MD)
	cat doc/requirements.md >> $(OVERVIEW_MD)

	echo "" >> $(OVERVIEW_MD)
	echo "##Videos" >> $(OVERVIEW_MD)
	if [ "$(VIDEOS)" != "" ] ; \
	   then \
	   mkdir -p     tmp/$(DIR)/Presentation/Video/ ; \
	   if [ -f doc/videos.md ] ;  \
	   then \
	        cat doc/videos.md >>  $(OVERVIEW_MD) ; \
	   else \
	        for vid in $(VIDEOS) ; \
		do \
		  VIDEO_MD_DIR=`dirname $$vid` ; \
		  echo "* $$vid" >>  $(OVERVIEW_MD) ; \
	        done ;\
	   fi ; \
	else \
		echo "No videos" >>  $(OVERVIEW_MD) ;\
	fi
#		  echo -n    "    Concepts: " >>  $(OVERVIEW_MD) && \
#		  cat "$(VIDEO_PATH)/$$VIDEO_MD_DIR/content.md" >>  $(OVERVIEW_MD) ; \


	echo "" >> $(OVERVIEW_MD)
	echo "##Reading instructions " >> $(OVERVIEW_MD)
	cat doc/reading.md >> $(OVERVIEW_MD)

	echo "" >> $(OVERVIEW_MD)
	echo "##Goal " >> $(OVERVIEW_MD)
	cat doc/goal.md >> $(OVERVIEW_MD)

	echo "" >> $(OVERVIEW_MD)
	echo "##Exam instructions " >> $(OVERVIEW_MD)
	cat doc/exam.md >> $(OVERVIEW_MD)

$(OVERVIEW_PDF): $(OVERVIEW_MD)

%.pdf:%.md
	@pandoc -o  $@ $<

%.pdf:%.tex
	@echo Creating pdf from tex file
	TEXINPUTS=$(MY_TEXINPUTS) xelatex -interaction=batchmode $<
	@mv $(shell basename $@) $@

%.pdf:%.pptx
	@echo Creating pdf from pptx file
	unoconv -f pdf $<
#	@mv $(shell basename $@) $@

check-exercises:
	@if [ "$(EXERCISES)" = "" ] ; then \
		echo " * " ;  \
		echo " * " ;  \
		echo " * ERROR Missing exercises *" ;  \
		echo " * " ;  \
		echo " * " ;  \
		echo " * " ;  \
		exit 1;       \
	elif [ "$(EXERCISES)" = ".ignore-exercises" ] ; then  \
		: ;\
	else \
		for dir in $(EXERCISES) ; do \
			if [ ! -s $$dir/Solutions/solution.md ] ; then echo "Missing solution ($$dir/Solutions/solution.md) for $$dir"; exit 1 ; fi ; \
		done ; \
	fi
	@echo "Checking exercise source code"
	@for file in $(EXERCISES_SRC) ; do \
		$(INDENT) $$file  >$(LOG_FILE) 2>&1  ; \
		echo -n  "  $$file: " && $(COMPILEFILE)  $$file && \
		echo "OK" || exit 1 ; \
        done
	@echo "Checking exercise extra file"
	@for file in $(EXERCISES_EXTRA) ; do \
		echo -n  "  $$file: " && $(COMPILEFILE)  $$file && \
		if [ ! -s $$file ] ; then echo "Missing extra file for $$dir"; exit 1 ; fi ; \
		echo "OK" || exit 1 ; \
        done
#	@for dir in $(EXERCISES) ; do \
#		echo "  $$dir:  " &&  cd $$dir && for file in `find ./* -prune -name "*.java"  ` ; do echo -n "    $$file: " && javac $$file && echo "OK" || echo "FAIL" && exit 1;  done ; cd - >/dev/null || exit 1 ; \
#	done
	@echo "Checking exercise source code: OK"
	@echo "Checking solution source code .... "
	@CLASSPATH=".:"
	@for file in $(SOLUTIONS_SRC) ; do \
		$(INDENT) $$file   >$(LOG_FILE) 2>&1   ; \
		CLASSPATH="`pwd`/`dirname $$file`:$$CLASSPATH" ; \
		echo -n  "  $$file: " && $(COMPILEFILE)  "$$file" "$$CLASSPATH" && \
		echo "OK" || exit 1; \
        done
#	@for dir in $(EXERCISES) ; do \
#		echo " $$dir " && cd $$dir/Solutions/ && for file in `find ./* -prune -name "*.java" ` ; do echo -n "    $$file: " && javac $$file && echo "OK" || ( echo "FAIL" && exit 1) ; done && rm -f *.class && cd - >/dev/null  || exit 1 ; \
		cd $$dir/Solutions/src && for file in `find ./* -prune -name "*.java" ` ; do echo -n "    $$file: " && javac $$file && echo "OK" || ( echo "FAIL" && exit 1) ; done && rm -f *.class && cd - >/dev/null  || exit 1 ; \
#	done
	@echo "Checking solution source code: OK"

clean: cleancrap
	@echo "Cleaning up"
	@rm -f $(IGNORE_EXERCISES)
	@rm -fr tmp gen *.aux *.log  *.nav  *.out *.snm *.toc 

dist:	clean cleancrap check check-exercises prepare  prepare-solution presentation solutions exercises overview dist solution-dist
	@-cp $(ALL_PDF)        tmp/$(DIR)/
	@mkdir -p             "$(LO_DIST_DIR)/"
	@mkdir -p             "$(LO_DIST_DIR)/"
	@chmod -R u+wr        "$(LO_DIST_DIR)/"
	@echo "copying to:     $(LO_DIST_DIR)/"
	cd tmp/ && cp -r */*  "$(LO_DIST_DIR)/"
	pwd
	ls -al tmp


local-dist: clean cleancrap check check-exercises prepare presentation exercises overview prepare-solution solutions
	-cp $(ALL_PDF) tmp/$(DIR)/
	-cp $(SOLUTIONS_PDF) $(ALL_PDF) tmp/$(DIR)/
	cd tmp/ && zip -r ../$(ZIP_FILE) $(DIR)

solution-dist:  clean cleancrap check check-exercises prepare-solution exercises overview 
	-cp $(SOLUTIONS_PDF) $(ALL_PDF) tmp/$(DIR)/
	cd tmp/ && zip -r ../$(SOL_ZIP_FILE) $(DIR)



