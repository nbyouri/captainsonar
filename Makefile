SRC=*.oz
TARGET=Main.ozf

all:
	@for src in ${SRC}; do \
	ozc $$src;	\
	done
	ozengine ${TARGET}
