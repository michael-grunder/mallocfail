CC=gcc
INSTALL=install
PREFIX?=/usr/local
CFLAGS=-Wall -ggdb -O2 -Ideps/uthash -Ideps/sha3 -Isrc
LDFLAGS=

LIBNAME=libmallocfail
DYLIBSUFFIX=so
PKGCONFNAME=mallocfail.pc

MALLOCFAIL_MAJOR=$(shell grep MALLOCFAIL_MAJOR src/mallocfail.h | awk '{print $$3}')
MALLOCFAIL_MINOR=$(shell grep MALLOCFAIL_MINOR src/mallocfail.h | awk '{print $$3}')
MALLOCFAIL_PATCH=$(shell grep MALLOCFAIL_PATCH src/mallocfail.h | awk '{print $$3}')
MALLOCFAIL_SONAME=$(shell grep MALLOCFAIL_SONAME src/mallocfail.h | awk '{print $$3}')
DYLIB_MINOR_NAME=$(LIBNAME).$(DYLIBSUFFIX).$(MALLOCFAIL_SONAME)
DYLIBNAME=$(LIBNAME).$(DYLIBSUFFIX)

.PHONY : all test clean install

all : mf_test $(DYLIBNAME)

libmallocfail.o : src/mallocfail.c
	$(CC) -c $(CFLAGS) -fPIC -o $@ $<

memory_funcs.o : src/memory_funcs.c
	$(CC) -c $(CFLAGS) -fPIC -o $@ $<

sha3.o : deps/sha3/sha3.c
	$(CC) -c $(CFLAGS) -fPIC -o $@ $<

mf_test.o : mf_test.c
	$(CC) -c $(CFLAGS) -o $@ $<

#DYLIB_MAKE_CMD=$(CC) -shared -Wl,-soname,$(DYLIB_MINOR_NAME)
$(DYLIBNAME) : libmallocfail.o memory_funcs.o sha3.o
	$(CC) -shared -Wl,-soname,$(DYLIB_MINOR_NAME) -o $@ $^ ${LDFLAGS} -fPIC -ldl -lbacktrace

mf_test : mf_test.o
	$(CC) -o $@ $^ ${LDFLAGS}

test : mf_test mallocfail.so
	LD_PRELOAD=./mallocfail.so ./mf_test

clean :
	-rm -f *.o *.so mf_test mallocfail_hashes.txt $(PKGCONFNAME)

install : $(DYLIBNAME) $(PKGCONFNAME) 
	mkdir -p $(PREFIX)/lib $(PREFIX)/include $(PREFIX)/lib/pkgconfig
	$(INSTALL) src/mallocfail.h $(PREFIX)/include
	$(INSTALL) $(DYLIBNAME) $(PREFIX)/lib/$(DYLIB_MINOR_NAME)
	cd $(PREFIX)/lib && ln -sf $(DYLIB_MINOR_NAME) $(DYLIBNAME)
	$(INSTALL) $(PKGCONFNAME) $(PREFIX)/lib/pkgconfig

$(PKGCONFNAME): src/mallocfail.h
	@echo "Generating $@ for pkgconfig..."
	@echo prefix=$(PREFIX) > $@
	@echo exec_prefix=\$${prefix} >> $@
	@echo libdir=\$${prefix}/lib >> $@
	@echo includedir=$(PREFIX)/include >> $@
	@echo >> $@
	@echo Name: mallocfail >> $@
	@echo Description: Hacked mallocfail for my own use >> $@
	@echo Version: $(MALLOCFAIL_MAJOR).$(MALLOCFAIL_MINOR).$(MALLOCFAIL_PATCH) >> $@
	@echo Libs: -L\$${libdir} -lmallocfail >> $@
	@echo Cflags: -I\$${includedir} >> $@
	#@echo Cflags: -I\$${includedir} -D_FILE_OFFSET_BITS=64 >> $@
