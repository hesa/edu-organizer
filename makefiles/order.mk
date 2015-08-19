EDUO_PATH=/home/hesa/opt/edu-organizer/

all: graphs

graphs: $(PNGS) 

%.svg: Makefile
%.svg:%.mk
	$(eval TARGS=$(shell $(EDUO_PATH)/bin/mk.sh $<))
	@echo "  Checking targets"
	for targ in $(TARGS) ; do \
		echo " * checking target '$$targ' in '$FILE'" ; \
		$(EDUO_PATH)/bin/mk.sh $< $$targ || exit 1 ; \
	done
	$(EDUO_PATH)/bin//makefile2dot.py < $< | dot -Tsvg -o $@

%.jpg:%.svg
	convert $<  $@

%.png:%.svg
	convert $<  $@
#	echo "done"

check-lo: 
	@echo "Checking Learning Objects in all mk: $(MKS)" 
	@for mk in $(MKS) ; do \
		echo   " * check: $$mk" ;\
		$(EDUO_PATH)/bin//check-lo.sh $$mk "$(LOS_PATHS)" || exit 1 ;\
	done

lo:
	for targ in $(TARGS) ; do echo "    targ: $$targ" ; done ;\

#for targ in $(shell ./mk.sh $$MK) ; do \
		#	echo " * checking target '$$targ' in LO" ; \
		#done ;\



clean:
	@echo Cleaning up
	@-rm -f *.dot *.jpg *.png *.html *~ *.svg uber.mk most.mk 
	@-rm -fr .makepp tmp.mk
