include variable.mk
CC_PATH = D:/share2/VC/bin/amd64
CC = $(CC_PATH)/cl.exe
SDK_Version=10.0.14393.0
export include = D:\share2\VC\include;D:\share2\Windows Kits\10\Include\$(SDK_Version)\ucrt;D:\share2\Windows Kits\10\Include\$(SDK_Version)\um;D:\share2\Windows Kits\10\Include\$(SDK_Version)\winrt;D:\share2\Windows Kits\10\Include\$(SDK_Version)\shared;.\inc;
export lib = D:\share2\Windows Kits\10\Include\$(SDK_Version)\shared;D:\share2\VC\lib\amd64;D:\share2\Windows Kits\10\Lib\$(SDK_Version)\ucrt\x64;D:\share2\Windows Kits\10\Lib\$(SDK_Version)\um\x64;
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SRC:.c=.obj)))
vpath %.c $(sort $(dir $(SRC)))
OBJECTS2 = $(addprefix ./,$(notdir $(SRC:.c=.obj)))
all:$(target).exe

$(BUILD_DIR)/%.obj: %.c Makefile | $(BUILD_DIR) 
	$(CC) -source-charset:gbk $(DEF) $(SRC_FLAG) -Zi -EHsc $< -Fo$@ -c
$(target).exe:$(OBJECTS) | Makefile
	@echo $(OBJECTS)
	$(CC_PATH)/link.exe -nologo -DEBUG -incremental:no -STACK:0x4000000 $(OBJECTS) -OUT:$(target).exe

$(BUILD_DIR):
	mkdir $@

clean:
	-rm -fR $(BUILD_DIR)
	-rm -fR *.obj
#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)
