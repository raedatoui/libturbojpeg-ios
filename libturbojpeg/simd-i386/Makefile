.DEFAULT_GOAL: libsimd

libsimd_objects = jsimdcpu.o \
	jfdctflt-3dn.o   jidctflt-3dn.o   jquant-3dn.o \
	jccolor-mmx.o    jcgray-mmx.o     jcsample-mmx.o \
	jdcolor-mmx.o    jdmerge-mmx.o    jdsample-mmx.o \
	jfdctfst-mmx.o   jfdctint-mmx.o   jidctfst-mmx.o \
	jidctint-mmx.o   jidctred-mmx.o   jquant-mmx.o \
	jfdctflt-sse.o   jidctflt-sse.o   jquant-sse.o \
	jccolor-sse2.o   jcgray-sse2.o    jcsample-sse2.o \
	jdcolor-sse2.o   jdmerge-sse2.o   jdsample-sse2.o \
	jfdctfst-sse2.o  jfdctint-sse2.o  jidctflt-sse2.o \
	jidctfst-sse2.o  jidctint-sse2.o  jidctred-sse2.o  \
	jquantf-sse2.o   jquanti-sse2.o

BUILD_DIR=build

libsimd: prepare build/jsimdcfg.inc jsimd_i386
	cd build && xcrun ar -r libsimd-i386.a $(libsimd_objects) "jsimd_i386.o"
	
.PHONY: clean

clean:
	rm -rf "$(BUILD_DIR)"

prepare:
	mkdir -p "$(BUILD_DIR)"
	
jsimd_i386: $(libsimd_objects)
	xcrun --sdk iphonesimulator clang -c -m32 -march=i386 -I".." -I"../.." -I"../../libjpeg" -c "jsimd_i386.c" -o "$(BUILD_DIR)/jsimd_i386.o"
	
build/jsimdcfg.inc: jsimdcfg.inc.h ../jpeglib.h ../../libjpeg/jconfig.h ../../libjpeg/jmorecfg.h ../../libjpeg/jconfigint.h
	xcrun cpp -I"../../libjpeg" $< | egrep "^[\;%]|^\ %" | sed 's%_cpp_protection_%%' | sed 's@% define@%define@g' >"$@"

%.o: %.asm 
	/usr/bin/nasm -f macho -DMACHO -DPIC -I. -I"$(BUILD_DIR)/" -o "$(BUILD_DIR)/$@" "$<"	
	
jccolor-mmx.o:   jccolext-mmx.asm
jcgray.-mmx.o:   jcgryext-mmx.asm
jdcolor-mmx.o:   jdcolext-mmx.asm
jdmerge-mmx.o:   jdmrgext-mmx.asm
jccolor-sse2.o:  jccolext-sse2.asm
jcgray-sse2.o:   jcgryext-sse2.asm
jdcolor-sse2.o:  jdcolext-sse2.asm
jdmerge-sse2.o:  jdmrgext-sse2.asm
