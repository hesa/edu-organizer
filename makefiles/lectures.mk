EDUO_PATH=/home/hesa/opt/edu-organizer/


include ${EDUO_PATH}/makefiles/settings.mk

NAME=$(shell pwd | xargs basename)
ifeq (${DIST_DIR}, '')
DIST_DIR=$(DIST_DIR_BASE)/Lecture/$(NAME)
endif



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

dist:
	@echo "Looping through LearningObjects $$LEC_NAME:"
	@LO_CTR=0 ; for dir in $(LOS) ; do \
		LO_CTR=` echo $$LO_CTR + 1 | bc` ;\
		LO_CTR2=`printf "%.2d" $$LO_CTR` ;\
		LO_NAME="$$LO_CTR2"-`basename $$dir` ;\
		echo " * making dist of: $$LEC_NAME/$$LO_NAME || $$LO_CTR $$LO_CTR2 " ; \
		cd $(LO_PATH)/$$dir && make LEC_NAME=$$LEC_NAME LO_NAME=$$LO_NAME dist    >>$(LOG_FILE) 2>&1 || exit 1 ; \
	done ; 


clean:

megaclean: clean
	@echo "Cleaning up LearningObjects $$LEC_NAME:"
	@LO_CTR=0 ; for dir in $(LOS) ; do \
		cd $(LO_PATH)/$$dir && make clean ;\
	done ; 
