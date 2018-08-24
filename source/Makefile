################################################################################
# Makefile
################################################################################

# Windows Paths
Windows.AVRBIN	      = d:/Programme/Arduino/hardware/tools/avr/bin
Windows.AVRETC	      = d:/Programme/Arduino/hardware/tools/avr/etc
Windows.RM            = del
Windows.arduino.PORT  = COM5
Windows.stk500v1.PORT = COM4

# Linux Paths
Linux.AVRBIN          = /usr/bin
Linux.AVRETC          = /etc
Linux.RM              = /bin/rm -f
Linux.arduino.PORT    = /dev/UnoClone
Linux.stk500v1.PORT   = /dev/AVRprog

# Avrdude Parameters
arduino.BAUD          = 115200
arduino.ERASE         = -D
stk500v1.BAUD         = 19200
stk500v1.ERASE        = 

# Default Target
	# Windows | Linux
OS	?= Linux
	# attiny{24,25,44,45,84,85} | atmega{8,328p}
MCU	?= attiny85
	# arduino | stk500v1
PROG	?= stk500v1

################################################################################
# Source Files
################################################################################

Main	= ledLamp
SrcAsm	= boot.$(MCU) $(Main) 
IncAsm	= ports.$(MCU) settings
SrcCpp	= ledMatrix ball pump flow constCol rain multiCol
IncCpp	= ledMatrix
Eeprom	       = -U eeprom:w:0x04,0x00,0x02,0x7f:m
Fuses.attiny85 = -U lfuse:w:0xff:m -U hfuse:w:0xd7:m -U efuse:w:0xff:m

################################################################################
# nothing to be configured below
################################################################################

AVRBIN = $($(OS).AVRBIN)
AVRETC = $($(OS).AVRETC)
RM     = $($(OS).RM)

AVRDUDE	= $(AVRBIN)/avrdude
CXX	= $(AVRBIN)/avr-g++
AS	= $(AVRBIN)/avr-as
LD	= $(AVRBIN)/avr-ld
OBJCOPY	= $(AVRBIN)/avr-objcopy
OBJDUMP	= $(AVRBIN)/avr-objdump
BootSetup = ruby ../../BootSetup/BootSetup.rb

PORT	?= $($(OS).$(PROG).PORT)
BAUD	?= $($(PROG).BAUD)
ERASE	?= $($(PROG).ERASE)

DEFSYM.attiny24   = 24
DEFSYM.attiny44   = 44
DEFSYM.attiny84   = 84
DEFSYM.attiny25   = 25
DEFSYM.attiny45   = 45
DEFSYM.attiny85   = 85
DEFSYM.atmega8    = 8
DEFSYM.atmega328p = 328
DEFSYM = $(DEFSYM.$(MCU))

################################################################################
# Rules
################################################################################

ObjAsm  = $(addsuffix .$(MCU).o,$(SrcAsm))
ObjCpp	= $(addsuffix .$(MCU).o,$(SrcCpp))

.PHONY:	ALL

ALL:	$(Main).$(MCU).hex

boot.$(MCU).asm ports.$(MCU).inc: Config.$(MCU)
	$(BootSetup) -c Config.$(MCU)

%.$(MCU).o %.o: %.asm $(addsuffix .inc, $(IncAsm))
	$(AS) -g -mmcu=$(MCU) -defsym __MCU__=$(DEFSYM) -o $@ $<

%.$(MCU).o: %.cpp $(addsuffix .h, $(IncCpp))
	$(CXX) -DRAMSIZE=$(RAMSIZE) -O2 -Wall -std=c++11 -c -mmcu=$(MCU) -DAVR -o $@ $<

$(Main).$(MCU).elf: $(ObjAsm) $(ObjCpp)
	$(LD) -o $@ $(ObjAsm) $(ObjCpp)

%.hex: %.elf
	$(OBJCOPY) -O ihex -R .eeporm $< $@

################################################################################
# PHONY targets

AVRDUDEParam = -C $(AVRETC)/avrdude.conf -p $(MCU) -c $(PROG) -P $(PORT) -b $(BAUD)

.PHONY:	Upload Clean Eeprom Fuses Dism Help

Upload: $(Main).$(MCU).hex
	$(AVRDUDE) $(AVRDUDEParam) $(ERASE) -U flash:w:$<:i

Clean:
	$(RM) boot.*.asm ports.*.inc *.o *.elf *.hex *.dism *~

ifneq ($(Eeprom),)
Eeprom:
	$(AVRDUDE) $(AVRDUDEParam) $(Eeprom)
endif

ifneq ($(Fuses.$(MCU)),)
Fuses:
	$(AVRDUDE) $(AVRDUDEParam) $(Fuses.$(MCU))
endif

Dism:	$(Main).$(MCU).elf
	$(OBJDUMP) -D -m avr5 $< > $(Main).$(MCU).dism

Help:
	@echo 'make [OS=Linux|Windows] [MCU=atmega328p|attiny45|...] [PROG=arduino|stk500v1] [Upload] [Clean] [Eeprom] [Fuses] [Help]'

################################################################################
# EOF
################################################################################
