# build tools & options
CL65 = cl65
CLFLAGS  = -v -d -t none -O --cpu 6502 -C $(LIB)/sbc.cfg -m $*.map
HEXDUMP = hexdump
HEXDUMP_ARGS = -v -e '1/1 "%02x " "\n"'
XXD = xxd
XXD_ARGS = -i
LIB=lib

%.hex: %.bin
	$(HEXDUMP) $(HEXDUMP_ARGS) $< > $@

%.bin: %.s $(LIB)/interrupt.s $(LIB)/vectors.s $(LIB)/copydata.s
	$(CL65) $(CLFLAGS) -Ln $*.lbl -o $@ $^

%.h: %.bin
	#cp $< /tmp/rom.bin
	#( cd /tmp; $(XXD) $(XXD_ARGS) rom.bin ) > $@
	xxd -i $< | sed -e "s/unsigned char $*_bin\[\]/const byte rom_bin\[\] PROGMEM/" > $@
	cp $@ ../mega/rom.h

clean:
	-rm -f *.o *.hex *.map *.bin *.h *.lbl
