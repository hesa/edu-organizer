all: graphs

graphs: $(PNGS) 

%.svg: Makefile
%.svg:%.mk
	$(eval TARGS=$(shell ./mk.sh $<))
	echo "  Checking targets"
	for targ in $(TARGS) ; do \
		echo " * checking target '$$targ' in '$FILE'" ; \
		./mk.sh $< $$targ || exit 1 ; \
	done
	/home/hesa/edu/VCS/C/old/order/makefile2dot.py < $< | dot -Tsvg -o $@

%.jpg:%.svg
	convert $<  $@

%.png:%.svg
	convert $<  $@
#	echo "done"

check-lo: 
	@echo "Checking Learning Objects in all mk: $(MKS)" 
	@for mk in $(MKS) ; do \
		echo   " * check: $$mk" ;\
		./check-lo.sh $$mk "$(LOS_PATHS)" || exit 1 ;\
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
