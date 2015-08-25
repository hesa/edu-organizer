EDUO_PATH=/home/hesa/opt/edu-organizer/


include ${EDUO_PATH}/makefiles/settings.mk


EDUO_BIN_PATH=${EDUO_PATH}/bin

#LEC_PATH=/home/hesa/edu/VCS/Lectures
#LOS_PATH=/home/hesa/edu/VCS/LearningObjects
export LEC_CTR=0

DATE=$(shell date '+%Y-%m-%d-%H%M%S')
NAME=$(shell pwd | xargs basename)
export DIST_DIR=$(DIST_DIR_BASE)/$(NAME)

LOG_FILE=/tmp/edu-organiser-$(USER).log

all: check

check:
	@echo "Checking presence of lectures:"
	@for dir in $(LECTURES) ; do \
		echo -n " $$dir, " ; \
		if [ ! -d  $(LEC_PATH)/$$dir ] ; then echo "Missing Lecture: $$dir "; exit 1 ; fi ; \
	done ;
	@echo 

deep-check: check
	@echo "Checking lecture content:"
	@for dir in $(LECTURES) ; do \
		echo -n " $$dir:   '$(LEC_PATH)' '$(shell pwd)'" ; \
		cd  $(LEC_PATH)/$$dir && make check || exit 1 ;\
		cd -  2>/dev/null >/dev/null ;\
		echo " OK ";\
	done ; 
	@echo ""


deepest-check: check
	@echo "Checking lecture content:"
	@for dir in $(LECTURES) ; do \
		echo -n " $$dir:   '$(LEC_PATH)' '$(shell pwd)'" ; \
		cd  $(LEC_PATH)/$$dir && make deep-check || exit 1 ;\
		cd -  2>/dev/null >/dev/null ;\
		echo " OK ";\
	done ; 
	@echo ""


list-los:
	@$(EDUO_BIN_PATH)/find-concepts $(LEC_PATH) $(LOS_PATH)  --detailed $(LECTURES)

ls:
	@$(EDUO_BIN_PATH)/find-concepts $(LEC_PATH) $(LOS_PATH)  --stdout  $(LECTURES)

lsd:
	@$(EDUO_BIN_PATH)/find-concepts $(LEC_PATH) $(LOS_PATH)  --stdout-detailed  $(LECTURES)

concepts.md:
	@$(EDUO_BIN_PATH)/find-concepts $(LEC_PATH) $(LOS_PATH)  --mega-detailed $(LECTURES)

course-content.md:
	@$(EDUO_BIN_PATH)/find-concepts $(LEC_PATH) $(LOS_PATH)  --mega-detailed $(LECTURES)

big-overview: course-content.pdf concepts.pdf

%.pdf:%.md
	@echo "Generating $@ from $<" 
	@pandoc $< -o $@

#overview: check
overview: check overview.pdf overview.md 

overview.md.old: 
	@echo "Generating $@, compiling lectures"
	@echo "# Lectures" > overview.md
	@LEC_NR=1 
	@for dir in $(LECTURES) ; do \
		LEC_NR=$$(( $$LEC_NR + 1 )) ;\
		echo -n  " $$dir," ; \
		echo  "" >> overview.md; \
		echo -n  "## Lecture $$LEC_NR: " >> overview.md; \
		grep "NAME=" $(LEC_PATH)/$$dir/Makefile | sed 's,[A-Z]*=,,g' >> overview.md ;\
		echo  " " >> overview.md; \
		cat $(LEC_PATH)/$$dir/doc/introduction.md 2>/dev/null  >> overview.md;\
		echo -n " " ;\
		echo  " " >> overview.md; \
		echo  " (lecture dir: $$dir)" >> overview.md; \
	done
	@echo "" ; \
#		echo -n  "__Type:__ " >> overview.md; \
#		grep "TYPE=" $(LEC_PATH)/$$dir/Makefile | sed 's,[A-Z]*=,,g' >> overview.md ;\

#		cat $(LEC_PATH)/$$dir/introduction.md || exit 1 ;\

#overview: check
detail: check detail.pdf detail.md
detail.md: 
	@echo "Generating $@, compiling lectures"
	@echo "# Lectures" > detail.md
	@LEC_NR=1 
	for dir in $(LECTURES) ; do \
		export MYDIR=$$dir ;\
		LEC_NR=$$(( $$LEC_NR + 1 )) ;\
		echo -n  " $$dir," ; \
		echo  "" >> detail.md; \
		echo -n  "## Lecture $$LEC_NR: " >> detail.md; \
		grep "NAME=" $(LEC_PATH)/$$dir/Makefile | sed 's,[A-Z]*=,,g' >> detail.md ;\
		echo  " " >> detail.md; \
		echo -n  "__Type:__ " >> detail.md; \
		grep "TYPE=" $(LEC_PATH)/$$dir/Makefile | sed 's,[A-Z]*=,,g' >> detail.md ;\
		echo "" >> detail.md; \
		echo -n  "__Introduction:__ " >> detail.md; \
		cat $(LEC_PATH)/$$dir/doc/introduction.md 2>/dev/null  >> detail.md;\
		echo -n " " ;\
		echo  " " >> detail.md; \
		echo  " " >> detail.md; \
		echo  "### Learning objects:" >> detail.md;\
		for lec in $$(grep "LOS="  $(LEC_PATH)/$$dir/Makefile | sed 's,LOS=,,g' ) ; do echo  "* $$lec " ; done >> detail.md ; \
		echo "" >> detail.md;\
		echo  " " >> detail.md; \
		echo  " (lecture dir: $$dir)" >> detail.md; \
	done
	@echo "" ; \
#		cat $(LEC_PATH)/$$dir/introduction.md || exit 1 ;\


print-lecs:
	@for dir in $(LECTURES) ; do \
		echo $$dir ;\
	done

print-los:
	@for dir in $(LECTURES) ; do \
		echo $$dir ;\
		for lec in $$(grep "LOS="  $(LEC_PATH)/$$dir/Makefile | sed 's,LOS=,,g' ) ; do echo  "* $$lec " ; done  ; \
		echo "" ; \
	done

dist:
	@-rm -f    $(DIST_DIR)/*.zip
	@-mkdir -p $(DIST_DIR)/
	make big-overview && mv course-content.pdf concepts.pdf $(DIST_DIR)/
#	make list-los     
	@for dir in $(LECTURES) ; do \
		LEC_CTR=` echo $$LEC_CTR + 1 | bc` ;\
		LEC_CTR2=`printf "%.2d" $$LEC_CTR` ;\
		LEC_NAME="$$LEC_CTR2-"`basename $$dir` ;\
		mkdir -p $(DIST_DIR)/$$LEC_NAME ;\
		echo "Making dist in $$dir ($$LEC_NAME)" ; \
		cd $(LEC_PATH)/$$dir && make LEC_NAME=$$LEC_NAME  dist || exit 1 ; \
	done


megaclean: clean
	for dir in $(LECTURES) ; do \
		cd $(LEC_PATH)/$$dir && make megaclean ;\
	done

clean:
	rm -f overview.pdf overview.md detail.pdf detail.md course-content*.* concepts* *.md

tar:
	tar zcvf courseware-$(DATE).tar.gz $(EDUO_PATH) $(LEC_PATH)/ $(LO_PATH)/ Makefile


display-presentations: deep-check
	for dir in $(LECTURES) ; do \
		cd $(LEC_PATH)/$$dir && make display-presentations ;\
	done
