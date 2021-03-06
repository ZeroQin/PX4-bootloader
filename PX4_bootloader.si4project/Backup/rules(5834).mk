#
# Common rules for makefiles for the PX4 bootloaders
#

BUILD_DIR	 = $(BUILD_DIR_ROOT)/$(TARGET_FILE_NAME)#./build/px4fmuv2_bl

COBJS		:= $(addprefix $(BUILD_DIR)/, $(patsubst %.c,%.o,$(SRCS)))#./build/.../%.o
AOBJS		:= $(addprefix $(BUILD_DIR)/, $(patsubst %.S,%.o,$(ASRCS)))#./build/.../%.S
SUBDIRS		:= $(sort $(addprefix $(BUILD_DIR)/, $(dir $(ASRCS))) $(addprefix $(BUILD_DIR)/, $(dir $(SRCS))) )#所有目标文件子目录(.o .s)
OBJS		:= $(COBJS) $(AOBJS)#所有目标文件
DEPS		:= $(COBJS:.o=.d)

ELF		 = $(BUILD_DIR)/$(TARGET_FILE_NAME).elf
HEX		 = $(BUILD_DIR)/$(TARGET_FILE_NAME).hex
BINARY		 = $(BUILD_DIR)/$(TARGET_FILE_NAME).bin

FLAGS		+= -Xlinker -Map=$(BUILD_DIR)/${TARGET_FILE_NAME}.map

all:	debug $(BUILD_DIR) $(ELF) $(BINARY) $(HEX)

debug:
#	@echo SRCS=$(SRCS)
#	@echo COBJS=$(COBJS)
#	@echo ASRCS=$(ASRCS)
#	@echo AOBJS=$(AOBJS)
#	@echo SUBDIRS=$(SUBDIRS)


# Compile and generate dependency files
$(BUILD_DIR)/%.o:	%.c
	@echo Generating object $@
	$(CC) -c -MMD $(FLAGS) -o $@ $<

$(BUILD_DIR)/%.o:	%.S
	@echo Generating object $@
	$(CC) -c -MMD $(FLAGS) -o $@ $*.S

# Make the build directory
$(BUILD_DIR) $(SUBDIRS):
	mkdir -p $(BUILD_DIR) $(SUBDIRS)

$(ELF):		$(OBJS) $(MAKEFILE_LIST)
	$(CC) -o $@ $(OBJS) $(FLAGS)

$(BINARY):	$(ELF)
	$(OBJCOPY) -O binary $(ELF) $(BINARY)

$(HEX):	$(ELF)
	$(OBJCOPY) -Oihex $(ELF) $(HEX)

# Dependencies for .o files
-include $(DEPS)
