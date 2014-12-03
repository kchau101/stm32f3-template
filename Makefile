# Based on the stm32f3-discovery-basic-template by mblythe86
#     Which was based on the stm32f0-discovery-basic-template by szczys
#  https://github.com/mblythe86/stm32f0-discovery-basic-template
#
#  Modified to suit a codelite type environment and my own purposes
#  to avoid copy pasting too much stuff.
#
#  Changes:
#    Modified to suit the STM32F3 Series
#  Kevin Chau Dec 2014
#
#    Doesn't use the included header files inside the ST Library.
#    You must copy these into the inc folder. This is so you can modify
#    oscillator frequency and whether to use the peripheral libraries.
#  Kevin Chau Aug 2014
#
#
# put your *.o targets here, make should handle the rest!
SRCS = main.c system_stm32f30x.c

# all the files will be generated with this name (main.elf, main.bin, main.hex, etc)
PROJ_NAME=main

# Location of the Libraries folder from the STM32F3xx Standard Peripheral Library
STD_PERIPH_LIB=../stm32f3-discovery-basic-template/Libraries

# Location of the linker scripts
LDSCRIPT_INC=../stm32f3-discovery-basic-template/Device/ldscripts

# location of OpenOCD Board .cfg files (only used with 'make program')
OPENOCD_BOARD_DIR=/usr/share/openocd/scripts/board

# Configuration (cfg) file containing programming directives for OpenOCD
OPENOCD_PROC_FILE=../stm32f3-discovery-basic-template/extra/stm32f3-openocd.cfg

# that's it, no need to change anything below this line!

###################################################

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy
OBJDUMP=arm-none-eabi-objdump
SIZE=arm-none-eabi-size

CFLAGS  = -Wall -g -std=c99 -Os  
CFLAGS += -mlittle-endian -mcpu=cortex-m4  -march=armv7e-m -mthumb
CFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS += -ffunction-sections -fdata-sections

CFLAGS += -Wl,--gc-sections -Wl,-Map=$(PROJ_NAME).map

###################################################

vpath %.c src
vpath %.a $(STD_PERIPH_LIB)

ROOT=$(shell pwd)

CFLAGS += -I inc -I $(STD_PERIPH_LIB)
CFLAGS += -I $(STD_PERIPH_LIB)/CMSIS/Include -I $(STD_PERIPH_LIB)/STM32F30x_StdPeriph_Driver/inc
CFLAGS += -include $(STD_PERIPH_LIB)/stm32f30x_conf.h

SRCS += $(STD_PERIPH_LIB)/../Device/startup_stm32f30x.s # add startup file to build

# need if you want to build with -DUSE_CMSIS
#SRCS += stm32f3_discovery.c
#SRCS += stm32f3_discovery.c stm32f3xx_it.c

OBJS = $(SRCS:.c=.o)

###################################################

.PHONY: lib proj

all: lib proj

lib:
	$(MAKE) -C $(STD_PERIPH_LIB)

proj: 	$(PROJ_NAME).elf

$(PROJ_NAME).elf: $(SRCS)
	$(CC) $(CFLAGS) $^ -o $@ -L$(STD_PERIPH_LIB) -lstm32f3 -L$(LDSCRIPT_INC) -Tstm32f3.ld
	$(OBJCOPY) -O ihex $(PROJ_NAME).elf $(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(PROJ_NAME).elf $(PROJ_NAME).bin
	$(OBJDUMP) -St $(PROJ_NAME).elf >$(PROJ_NAME).lst
	$(SIZE) $(PROJ_NAME).elf

program: $(PROJ_NAME).bin
	openocd -f $(OPENOCD_BOARD_DIR)/stm32f3discovery.cfg -f $(OPENOCD_PROC_FILE) -c "stm_flash `pwd`/$(PROJ_NAME).bin" -c shutdown

clean:
	find ./ -name '*~' | xargs rm -f
	rm -f *.o
	rm -f $(PROJ_NAME).elf
	rm -f $(PROJ_NAME).hex
	rm -f $(PROJ_NAME).bin
	rm -f $(PROJ_NAME).map
	rm -f $(PROJ_NAME).lst

reallyclean: clean
	$(MAKE) -C $(STD_PERIPH_LIB) clean
