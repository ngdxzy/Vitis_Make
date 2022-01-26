#
# this file was created by a computer. trust it.
#
# Project Name
PRJ_NAME ?= PRJ_NAME 
TARGET ?= sw_emu
# Host source files
HOST_SRC_DIR ?= host_src
HOST_SRC += $(HOST_SRC_DIR)/host.cpp
HOST_SRC += $(HOST_SRC_DIR)/xcl2.hpp
XCL2_SRC += $(HOST_SRC_DIR)/xcl2.cpp
XCL2_SRC += $(HOST_SRC_DIR)/xcl2.hpp

# Kernel souce files
KERNEL_SRC_DIR ?= kernel_src
KERNEL_SRC += $(KERNEL_SRC_DIR)/<source>
KERNEL_CONFIG += $(KERNEL_SRC_DIR)/<cfg>.cfg
# set kernel frequency if necessary
# KERNEL_EXT_CONFIG += --kernel_frequency
# KERNEL_EXT_CONFIG += 125 

# Bit Container Linker Configuration
BC_CONFIG += $(KERNEL_SRC_DIR)/<name>-link.cfg

XILINX_VITIS ?= /tools/Xilinx/Vitis/2021.2
XILINX_XRT ?= /opt/xilinx/xrt
XILINX_VIVADO ?= /tools/Xilinx/Vivado/2021.2
XILINX_HLS_INCLUDES ?= /tools/Xilinx/Vitis_HLS/2021.2/include


# Platform
VITIS_PLATFORM = xilinx_aws-vu9p-f1_shell-v04261818_201920_2
VITIS_PLATFORM_DIR = /home/alfred/Projects/Vitis/aws-fpga/Vitis/aws_platform/xilinx_aws-vu9p-f1_shell-v04261818_201920_2
VITIS_PLATFORM_PATH = $(VITIS_PLATFORM_DIR)/xilinx_aws-vu9p-f1_shell-v04261818_201920_2.xpfm

VPP_OPTS = --target $(TARGET)

# compiler tools
VPP_LINKER ?= ${XILINX_VITIS}/bin/v++
VPP ?= ${XILINX_VITIS}/bin/v++
HOST_CXX ?= g++
RM = rm -f
RMDIR = rm -rf
#
# host complie flags
CXXFLAGS += -std=c++1y -DVITIS_PLATFORM=$(VITIS_PLATFORM) -D__USE_XOPEN2K8 -I$(XILINX_XRT)/include/ -I$(XILINX_HLS_INCLUDES)/ -O2 -g -Wall -c -fmessage-length=0
LDFLAGS += -luuid -lxrt_coreutil -lxilinxopencl -lpthread -lrt -lstdc++ -L$(XILINX_XRT)/lib/ -Wl,-rpath-link,$(XILINX_XRT)/lib

BUILD_SUBDIRS += build
HW_KERNEL_OBJS += build/vitis_hls/kernel.xo

BINARY_CONTAINERS += build/vivado/bit_container.xclbin

XCL2_OBJ += build/host/xcl2.o
HOST_OBJ +=	build/host/host.o 
HOST_EXE = build/host/$(PRJ_NAME)

LOG_DIR ?= build/logs
REPORT_DIR ?= build/reports

RUN_EXE ?= $(PRJ_NAME)
RUN_BIN ?= bit_container.xclbin
#
# primary build targets
#

.PHONY: all clean host kernel link run
all: $(HW_KERNEL_OBJS) $(BINARY_CONTAINERS) $(HOST_EXE)
	-@cp $(HOST_EXE) ./
	-@cp $(BINARY_CONTAINERS) ./

host: $(HOST_EXE)


kernel: $(HW_KERNEL_OBJS)


link: $(BINARY_CONTAINERS)


run: $(RUN_EXE) $(RUN_BIN) emconfig.json
	export XCL_EMULATION_MODE=$(TARGET) && ./$(RUN_EXE) $(RUN_BIN)


clean:
	-$(RM) $(HW_KERNEL_OBJS) $(BINARY_CONTAINERS) *.log *.mdb 
	-$(RMDIR) $(BUILD_SUBDIRS)
	-$(RMDIR) .Xil
	-$(RM) *.json
	-$(RM) $(RUN_EXE)
	-$(RM) $(RUN_BIN)
	-$(RMDIR) .run
	-$(RMDIR) .ipcache

.PHONY: incremental
incremental: all


nothing:

# build kernel first
$(HW_KERNEL_OBJS): $(KERNEL_SRC) $(KERNEL_CONFIG)
	-@mkdir -p $(@D)
	-@mkdir -p $(LOG_DIR)
	-@mkdir -p $(REPORT_DIR)
	-@$(RM) $@
	faketime 'last year' $(VPP) $(VPP_OPTS) --temp_dir build/vitis_hls --log_dir $(LOG_DIR) --report_dir $(REPORT_DIR) --compile -I"$(<D)" --config $(KERNEL_CONFIG) $(KERNEL_EXT_CONFIG) -o"$@" "$<"


# link project secondly
$(BINARY_CONTAINERS): $(HW_KERNEL_OBJS) $(BC_CONFIG)
	-@mkdir -p $(@D)
	$(VPP_LINKER) $(VPP_OPTS) --link --config $(BC_CONFIG)  --temp_dir build/vivado --log_dir $(LOG_DIR) --report_dir $(REPORT_DIR) -R2 -o"$@" "$<"


# bulid host finally
$(HOST_EXE): $(XCL2_OBJ) $(HOST_OBJ)
	-@mkdir -p $(@D)
	$(HOST_CXX) -o "$@" $(+) $(LDFLAGS)


$(XCL2_OBJ): $(XCL2_SRC)
	-@mkdir -p $(@D)
	$(HOST_CXX) $(CXXFLAGS) -o "$@" "$<"


$(HOST_OBJ): $(HOST_SRC)
	-@mkdir -p $(@D)
	$(HOST_CXX) $(CXXFLAGS) -o "$@" "$<"

emconfig.json:
	-@emconfigutil --platform $(VITIS_PLATFORM_PATH)

