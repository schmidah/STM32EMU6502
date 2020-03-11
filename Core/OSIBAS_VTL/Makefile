######################################
# target
######################################
TARGET = osi_bas

######################################
# source
######################################
ASM_SOURCES = \
./vectors.asm \
./iohandler.asm \
./vtl02a2b.asm
S_SOURCES = \
./osi_bas.s

#######################################
# paths
#######################################
# Build path
BUILD_DIR = build

#######################################
# binaries
#######################################
AS = ca65
LD = ld65

#######################################
# ASMFLAGS
#######################################
ASFLAGS = -g -v

#######################################
# LDFLAGS
#######################################
LDSCRIPT = rom.cfg

# default action: build all
all: $(BUILD_DIR)/$(TARGET).bin

#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(S_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(S_SOURCES)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.asm=.o)))
vpath %.asm $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -l $(basename $@).lst $(ASFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.asm Makefile | $(BUILD_DIR)
	$(AS) -l $(basename $@).lst $(ASFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).bin: $(OBJECTS) Makefile
	$(LD) -C $(LDSCRIPT) -o $@ $(OBJECTS)

$(BUILD_DIR):
	mkdir $@

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)