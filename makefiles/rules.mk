DIR=$(shell pwd | xargs basename)
DATE=$(shell date '+%Y-%m-%d-%H%M%S')

TMP_DIR=tmp/

ZIP_FILE=$(DIR)-rev-$(DATE).zip
ZIP_SOLUT_FILE=$(DIR)-solutions-rev-$(DATE).zip


PRESENTATIONS=$(LO_PRESENTATIONS) $(LO_VIDEOS) 

ALL_FILES=$(VIDEOS) $(PRESENTATIONS) $(JAVA_FILES) instruktioner.pdf 


exercise:
	@echo " ---" $(dir)

EX=$(TMP_DIR)/Exercises/exercises.md
SOL=$(TMP_DIR)/Exercises/solutions.md
exercises:
	@mkdir -p tmp/Exercises/
	@-rm -f $(EX)
	@-rm -f $(SOL)
	@-echo  "# $(LO_NAME) Exercises " >> $(EX)
	@-echo  "# $(LO_NAME) Solutions " >> $(SOL)
	@-echo "" >> $(EX)
	@-echo "" >> $(EX)
	@for dir in $(LO_EXERCISES); do \
		echo -n "##"          >> $(EX) && \
		basename $$dir        >> $(EX) && \
		cat $$dir/question.md >> $(EX) && \
		echo -n "##"          >> $(SOL) && \
		basename $$dir        >> $(SOL) && \
		cat $$dir/solution.md >> $(SOL) && \
		NEW_DIR=$$(basename $$dir) && \
		cd $$dir/../ && pwd && make clean && cd - && \
		mkdir -p $(TMP_DIR)/Exercises/$$NEW_DIR && \
		cp -r $$dir/src/*.java $(TMP_DIR)/Exercises/$$NEW_DIR ;\
	done
	@-echo  "This document was generated: " >> $(EX)
	@-echo  -n " * date:        " >>  $(EX)
	@-date >>  $(EX)
	@-echo  -n " * on computer: " >>  $(EX)
	@-uname -n >> $(EX)
	@-echo "" >>  $(EX)
	@-echo "" >>  $(EX)

	@-echo  "This document was generated: " >> $(SOL)
	@-echo  -n " * date:        " >>  $(SOL)
	@-date >>  $(SOL)
	@-echo  -n " * on computer: " >>  $(SOL)
	@-uname -n >> $(SOL)
	@-echo "" >>  $(SOL)
	@-echo "" >>  $(SOL)


#	$(foreach dir,$(LO_EXRCISES), cd $(dir) && make ;)

check: $(ALL_FILES) 
	@echo "Everything seems ok, $(DATE)  :)"

instruktioner.pdf: instruktioner.md
	pandoc $< -o $@


all: dist solutions-dist

length:
	@../video-length $(VIDEOS)

dist:  $(ALL_FILES) 
	rm -fr tmp/$(DIR)
	mkdir -p tmp/$(DIR)
	mkdir -p tmp/$(DIR)/java
	mkdir -p tmp/$(DIR)/video
	mkdir -p tmp/$(DIR)/presentations
	mkdir -p tmp/$(DIR)/exercises


	if [ "$(VIDEOS)" != "" ] ; then cp $(VIDEOS)         tmp/$(DIR)/video/; fi
	cp $(PRESENTATIONS)  tmp/$(DIR)/presentations/
	cp $(EXRCISES)       tmp/$(DIR)/exercises
	cp instruktioner.pdf tmp/$(DIR)/
	../copyfiles "$(EXTRA_JAVA_FILES)" "tmp/$(DIR)"
	../copyfiles "$(JAVA_FILES)"     "tmp/$(DIR)/"

	cd     tmp/ && zip -r $(ZIP_FILE) $(DIR)
	cp tmp/$(ZIP_FILE) /home/hesa/Desktop/

solution-dist:  $(ALL_FILES) $(SOLUTIONS) 
	rm -fr tmp/$(DIR)
	mkdir -p tmp/$(DIR)
	mkdir -p tmp/$(DIR)/exercises
	mkdir -p tmp/$(DIR)/solutions

	cp $(EXRCISES)       tmp/$(DIR)/exercises
	../copyfiles "$(SOLUTIONS)"      "tmp/$(DIR)/solutions"

	cd     tmp/ && zip -r $(ZIP_SOLUT_FILE) $(DIR)/
	cp tmp/$(ZIP_SOLUT_FILE) /home/hesa/Desktop/
