DIR=$(shell pwd | xargs basename)
DATE=$(shell date '+%Y-%m-%d-%H%M%S')

ZIP_FILE=$(DIR)-$(DATE).zip
SOL_ZIP_FILE=$(DIR)-solutions-$(DATE).zip

OVERVIEW_MD_SRC=doc/goal.md  doc/introduction.md  doc/purpose.md  doc/requirements.md doc/reading.md doc/exam.md

EXERCISES_MD=gen/exercises.md
SOLUTIONS_MD=gen/solutions.md
OVERVIEW_MD=gen/overview.md 
EXAM_MD=gen/exam.md 
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

ALL_FILES=$(VIDEOS) $(EXAM_MD_SRC) $(OVERVIEW_MD_SRC) $(PRESENTATION) $(EXERCISES) $(EXERCISES_SRC) $(SOLUTIONS_SRC) $(JAVA_FILES) 


check: $(ALL_FILES) check-exercises 
	@if [ "$(VIDEOS)" = "" ] ;  then  echo " * Missing videos * " ;  fi
	@echo "Everything seems ok, $(DATE)  :)"

#instruktioner.pdf: instruktioner.md
#	pandoc $< -o $@


all: dist solutions-dist


purpose:
	cat doc/purpose.md



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

solutions: exercises $(SOLUTIONS_PDF)
exercises: 
	rm -fr gen
	make $(EXERCISES_PDF)
#$(EXERCISES_PDF)

$(SOLUTIONS_MD):
	if [ ! -d gen ] ; then mkdir gen ; fi
	@echo "# Solutions for $(DIR)" > $(SOLUTIONS_MD)
	@echo "" >> $(SOLUTIONS_MD)

	for dir in $(EXERCISES) ; do \
		SHORTNAME=`basename "$$dir" ` ; \
		if [ ! -s  $$dir/Solutions/solution.md ] ; then echo "Missing solution for: $$dir "; exit 1 ; \
		else \
			echo "## $$SHORTNAME" >> $(SOLUTIONS_MD) && \
			cat $$dir/Solutions/solution.md >> $(SOLUTIONS_MD) && \
			echo "" >> $(SOLUTIONS_MD) && \
			echo "" >> $(SOLUTIONS_MD) ; \
		fi ; \
	done ; 
	if [ "$(SOLUTIONS_SRC)" != "" ] ; then \
		echo "Copying solution sources: " ; \
		../../copyfiles-coded "$(SOLUTIONS_SRC)" tmp/$(DIR)/$$dir/ ; \
	fi

$(EXERCISES_MD): 
	if [ ! -d gen ] ; then mkdir gen ; fi
	@echo "# Exercises for $(DIR)" > $(EXERCISES_MD)
	@echo "" >> $(EXERCISES_MD)

	for dir in $(EXERCISES) ; do \
		SHORTNAME=`basename "$$dir" ` ; \
		if [ ! -s  $$dir/question.md ] ; then echo "Missing Exercise for: $$dir "; exit 1 ; \
		else \
			echo "## $$SHORTNAME  " >> $(EXERCISES_MD)  && \
			cat $$dir/question.md >> $(EXERCISES_MD); \
			echo "" >> $(EXERCISES_MD); \
		fi ; \
		if [ ! -s  $$dir/Solutions/solution.md ] ; then echo "Missing solution for: $$dir "; exit 1 ; fi \
	done ; 
	if [ "$(EXERCISES_SRC)" != "" ] ; then \
		echo "Copying exercise sources: " ; \
		../../copyfiles-coded "$(EXERCISES_SRC)" tmp/$(DIR)/$$dir/ ; \
	fi

$(EXERCISES_MD): $(EXERCISES) 


presentation:
	if [ "$(VIDEOS)" != "" ] ; \
	   then \
	   mkdir -p     tmp/$(DIR)/Presentation/Video/ && \
	   cp $(VIDEOS) tmp/$(DIR)/Presentation/Video/ ; \
        fi
	if [ "$(PRESENTATION)" != "" ] ; \
	   then cp $(PRESENTATION) tmp/$(DIR)/Presentation/Slides; \
	fi
	if [ "$(PRESENTATION_SRC)" != "" ] ; \
	   then ../../copyfiles-coded "$(PRESENTATION_SRC)" tmp/$(DIR)/; \
	fi
	@echo "Checking presentation source code"
	@for file in $(PRESENTATION_SRC) ; do \
		echo -n  "  $$file: " && ../../compilefile  $$file && \
		echo "OK" || exit 1 ; \
        done

overview: $(OVERVIEW_PDF) Makefile

$(OVERVIEW_MD): $(OVERVIEW_MD_SRC)
	@for file in $(OVERVIEW_MD_SRC) ; do \
		echo "Check $$file"; if [ ! -s $$file  ] ; then exit 1; fi ; echo "$$file ok" ; \
	done

	if [ ! -d gen ] ; then mkdir gen ; fi
#	if [ ! -s $(OVERVIEW_MD) ] ; then exit 1; fi
	echo "#$(DIR)" > $(OVERVIEW_MD)
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

check-exercises:
	@if [ "$(EXERCISES)" = "" ] ; then  \
	echo " * Missing exercises" ; exit 1; \
	else \
		for dir in $(EXERCISES) ; do \
			if [ ! -s $$dir/Solutions/solution.md ] ; then echo "Missing solution ($$dir/Solutions/solution.md) for $$dir"; exit 1 ; fi ; \
		done ; \
	fi
	@echo "Checking exercise source code"
	@for file in $(EXERCISES_SRC) ; do \
		echo -n  "  $$file: " && ../../compilefile  $$file && \
		echo "OK" || exit 1 ; \
        done
#	@for dir in $(EXERCISES) ; do \
#		echo "  $$dir:  " &&  cd $$dir && for file in `find ./* -prune -name "*.java"  ` ; do echo -n "    $$file: " && javac $$file && echo "OK" || echo "FAIL" && exit 1;  done ; cd - >/dev/null || exit 1 ; \
#	done
	@echo "Checking exercise source code: OK"
	@echo "Checking solution source code .... "
	@CLASSPATH=".:"
	@for file in $(SOLUTIONS_SRC) ; do \
		CLASSPATH="`pwd`/`dirname $$file`:$$CLASSPATH" ; \
		echo -n  "  $$file: " && ../../compilefile  "$$file" "$$CLASSPATH" && \
		echo "OK" || exit 1; \
        done
#	@for dir in $(EXERCISES) ; do \
#		echo " $$dir " && cd $$dir/Solutions/ && for file in `find ./* -prune -name "*.java" ` ; do echo -n "    $$file: " && javac $$file && echo "OK" || ( echo "FAIL" && exit 1) ; done && rm -f *.class && cd - >/dev/null  || exit 1 ; \
		cd $$dir/Solutions/src && for file in `find ./* -prune -name "*.java" ` ; do echo -n "    $$file: " && javac $$file && echo "OK" || ( echo "FAIL" && exit 1) ; done && rm -f *.class && cd - >/dev/null  || exit 1 ; \
#	done
	@echo "Checking solution source code: OK"



clean: cleancrap
	@echo "Cleaning up"
	@rm -fr tmp gen 

dist:  clean cleancrap check check-exercises prepare presentation exercises overview $(ALL_PDF)
	cp $(ALL_PDF) tmp/$(DIR)/
	cd tmp/ && zip -r ../$(ZIP_FILE) $(DIR)

solution-dist:  clean cleancrap check check-exercises prepare-solution exercises overview $(SOLUTIONS_PDF)
	cp $(SOLUTIONS_PDF) $(ALL_PDF) tmp/$(DIR)/
	cd tmp/ && zip -r ../$(SOL_ZIP_FILE) $(DIR)



