EDUO_PATH=/home/hesa/opt/edu-organizer/
include ${EDUO_PATH}/makefiles/settings.mk

NAME=$(shell pwd | xargs basename)
export LEC_NAME=$(LEC_CNT)$(shell grep NAME Makefile | sed -e 's/NAME=//g' -e 's/ /\-/g' )
export LEC_NAME_DIR=$(LEC_CNT)$(shell grep NAME Makefile | sed -e 's/NAME=//g' -e 's/ /\-/g' )

ifeq (${DIST_DIR},)
DIST_DIR=$(DIST_DIR_BASE)/Lecture/$(LEC_NAME_DIR)
endif
export DIST_DIR

EDUO_BIN_PATH=${EDUO_PATH}/bin

LOG_FILE=/tmp/edu-organiser-$(USER).log

all: check

log:
	date >> $(LOG_FILE)

check:
	@echo "Looking for LearningObjects:"
	@for dir in $(LOS) ; do \
		echo -n " * $$dir: " ; \
		if [ ! -d  $(LO_PATH)/$$dir ] ; then echo ; echo "Missing LearningObject: $$dir in $(LO_PATH)/ "; exit 1 ; fi ; \
		echo " OK" ; \
	done ; 

name:
	@echo $(NAME)

type:
	@echo $(TYPE)

deep-check-old: check
	@echo "Checking LearningObjects:"
	@for dir in $(LOS) ; do \
		echo " * $$dir:" ; \
		echo -n "   * basic:" ; \
		cd  $(LO_PATH)/$$dir && make       >>$(LOG_FILE) 2>&1 || exit 1 ; \
		echo " OK" ; \
		echo -n "   * check:" ; \
		cd  $(LO_PATH)/$$dir && make check 2>/dev/null >/dev/null || exit 1 ; \
		echo " OK" ; \
		echo -n "   * distribution:" ; \
		cd  $(LO_PATH)/$$dir && make dist  2>/dev/null >/dev/null || exit 1 ;\
		echo " OK" ; \
		echo -n "   * solution-dist:" ; \
		cd  $(LO_PATH)/$$dir && make solution-dist  2>/dev/null >/dev/null || exit 1 ;\
		echo " OK" ; \
	done ; 

deep-check: check
	@echo "Checking LearningObjects:"
	@for dir in $(LOS) ; do \
		echo " * $$dir" ; \
		cd  $(LO_PATH)/$$dir && make deep-check    >>$(LOG_FILE) 2>&1 || exit 1 ; \
	done ; 

display-presentations: check
	@echo "Looping through LearningObjects:"
	@for dir in $(LOS) ; do \
		echo " * $$dir" ; \
		cd $(LO_PATH)/$$dir && make display-presentation    >>$(LOG_FILE) 2>&1 || exit 1 ; \
	done ; 

display-exercises: check
	@echo "Looping through LearningObjects (display exercises):"
	@for dir in $(LOS) ; do \
		echo " * $$dir" ; \
		cd $(LO_PATH)/$$dir && make display-exercises >>$(LOG_FILE) 2>&1 || exit 1 ; \
	done ; 

exercises: 
	@for dir in $(LOS) ; do \
		cd $(LO_PATH)/$$dir && make exercises || exit 1 ; \
	done ; 

all-exercises:
#		echo "# $$dir" >> $(EXERC) ; 
	@for dir in $(LOS) ; do \
		cd $(LO_PATH)/$$dir && make EXERC=$(EXERC) all-exercises || exit 1 ; \
	done ; 

all-solutions:
	@for dir in $(LOS) ; do \
		cd $(LO_PATH)/$$dir && make SOLS=$(SOLS) all-solutions || exit 1 ; \
	done ; 

dist:
	@echo "Looping through LearningObjects $$LEC_NAME:"
	@echo "  in lecture, DIST_DIR=$$DIST_DIR | $(DIST_DIR)"
	@LO_CTR=0 ; for dir in $(LOS) ; do \
		LO_CTR=` echo $$LO_CTR + 1 | bc` ;\
		LO_CTR2=`printf "%.2d-" $$LO_CTR` ;\
		echo " * making dist of: $$LEC_NAME_DIR/$$LO_NAME || $$LO_CTR $$LO_CTR2 " ; \
		cd $(LO_PATH)/$$dir && make DIST_DIR="$$DIST_DIR" LEC_CNT="$$LEC_CNT" LO_CNT=$$LO_CTR2 dist   || exit 1 ; \
	done ;
#  >>$(LOG_FILE) 2>&1
#
#		cd $(LO_PATH)/$$dir && make DIST_DIR="$(DIST_DIR)" LEC_NAME="$$LEC_NAME_DIR" dist || exit 1 ; \


clean:

megaclean: clean
	@echo "Cleaning up LearningObjects $$LEC_NAME:"
	@LO_CTR=0 ; for dir in $(LOS) ; do \
		cd $(LO_PATH)/$$dir && make clean ;\
	done ; 
