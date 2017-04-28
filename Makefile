SRC=*.oz
TARGET=Main.ozf

all:
	@for src in ${SRC}; do \
	ozc -c $$src;	\
	done
	ozengine ${TARGET}
