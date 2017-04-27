SRC=GUI.oz Input.oz Player100TargetPractice.oz PlayerManager.oz Main.oz 
TARGET=Main.ozf

all:
	@for src in ${SRC}; do \
	ozc $$src;	\
	done
	ozengine ${TARGET}
