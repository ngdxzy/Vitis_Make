################################################################################
# this file was created by alfred. Do not trust it.
#
# tool chain path
XILINX_VITIS ?= /tools/Xilinx/Vitis/2021.2
XILINX_XRT ?= /opt/xilinx/xrt
XILINX_VIVADO ?= /tools/Xilinx/Vivado/2021.2
XILINX_HLS_INCLUDES ?= /tools/Xilinx/Vitis_HLS/2021.2/include

JOBS ?= 8

# Platform path
VITIS_PLATFORM = xilinx_u280_xdma_201920_3

# Project Name
PRJ_NAME ?= demo
TARGET ?= hw_emu

# Interface
INTERFACE ?= 01

# Host source files
HOST_SRC_DIR ?= host_src
HOST_O_DIR ?= build/host

ifeq ($(INTERFACE), 01)
	HOST_TX_OBJ += $(HOST_O_DIR)/host_sender_if0.o
	HOST_RX_OBJ += $(HOST_O_DIR)/host_receiver_if0.o
endif

ifeq ($(INTERFACE), 10)
	HOST_TX_OBJ += $(HOST_O_DIR)/host_sender_if1.o
	HOST_RX_OBJ += $(HOST_O_DIR)/host_receiver_if1.o
endif

ifeq ($(INTERFACE), 11)
	HOST_TX_OBJ += $(HOST_O_DIR)/host_sender_if3.o
	HOST_RX_OBJ += $(HOST_O_DIR)/host_receiver_if3.o
endif
HOST_COMMON_OBJ += $(HOST_O_DIR)/xcl2.o
HOST_COMMON_OBJ += $(HOST_O_DIR)/fileops.o

# Kernel Source Path, do not modify
KERNEL_O_DIR ?= build/vitis_hls
KERNEL_SRC_DIR ?= kernel_src

# Kernel to build
# Automatic deduce that build all kernel_src/*.cpp to *.xo
# Make sure that each cpp file has only one kernel
HW_KERNEL_SRCS := $(wildcard $(KERNEL_SRC_DIR)/*.cpp)
HW_KERNEL_OBJS := $(patsubst $(KERNEL_SRC_DIR)%.cpp,$(KERNEL_O_DIR)%.xo,$(HW_KERNEL_SRCS))
HW_KERNEL_HEADERS := $(wildcard $(KERNEL_SRC_DIR)/*.hpp)

HW_COMMON_KERNELS += Base_IPs/networklayer.xo
ifeq ($(INTERFACE), 01)
	HW_COMMON_KERNELS += Base_IPs/cmac_0.xo
endif

ifeq ($(INTERFACE), 10)
	HW_COMMON_KERNELS += Base_IPs/cmac_1.xo
endif

ifeq ($(INTERFACE), 11)
	HW_COMMON_KERNELS += Base_IPs/cmac_0.xo
	HW_COMMON_KERNELS += Base_IPs/cmac_1.xo
endif
# Setup debuging
# The debuging setup is in debuging_setup.ini
XRT_INI_CONFIG := ./debuging_setup.ini

# set kernel frequency if necessary
KERNEL_EXT_CONFIG += --kernel_frequency
KERNEL_EXT_CONFIG += 250

# Bit Container Linker Configuration, edit independently
ifeq ($(INTERFACE), 01)
	BC_CONFIG = $(KERNEL_SRC_DIR)/connectivity_if0.ini
endif

ifeq ($(INTERFACE), 10)
	BC_CONFIG = $(KERNEL_SRC_DIR)/connectivity_if1.ini
endif

ifeq ($(INTERFACE), 11)
	BC_CONFIG = $(KERNEL_SRC_DIR)/connectivity_if3.ini
endif





################################################################################
################# do not modify contents below if not necessary ################
################################################################################
VPP_OPTS = --target $(TARGET)

# compiler tools
VPP_LINKER ?= ${XILINX_VITIS}/bin/v++
VPP ?= ${XILINX_VITIS}/bin/v++
HOST_CXX ?= g++
RM = rm -f
RMDIR = rm -rf
#
# host complie flags
CXXFLAGS += -std=c++1y -DVITIS_PLATFORM=$(VITIS_PLATFORM) -D__USE_XOPEN2K8 -I$(XILINX_XRT)/include/ -I$(XILINX_HLS_INCLUDES)/ -I$(HOST_SRC_DIR)/ -O2 -g -Wall -c -fmessage-length=0
LDFLAGS += -luuid -lxrt_coreutil -lxilinxopencl -lxrt_core -lpthread -lrt -lstdc++ -L$(XILINX_XRT)/lib/ -Wl,-rpath-link,$(XILINX_XRT)/lib

BUILD_SUBDIRS += build

BINARY_CONTAINER += build/vivado/bit_container.xclbin

HOST_TX_EXE = build/host/$(PRJ_NAME)_tx
HOST_RX_EXE = build/host/$(PRJ_NAME)_rx

LOG_DIR ?= build/logs
REPORT_DIR ?= build/reports

RUN_EXE ?= $(PRJ_NAME)
RUN_BIN ?= bit_container.xclbin

KERNEL_EXT_CONFIG += --platform
KERNEL_EXT_CONFIG += $(VITIS_PLATFORM)
KERNEL_EXT_CONFIG += --temp_dir
KERNEL_EXT_CONFIG += build/vitis_hls
KERNEL_EXT_CONFIG += --log_dir
KERNEL_EXT_CONFIG += $(LOG_DIR)
KERNEL_EXT_CONFIG += --report_dir
KERNEL_EXT_CONFIG += $(REPORT_DIR)
KERNEL_EXT_CONFIG += -s
BC_EXT_CONFIG += -s

# If it is hardware emulation, the debug hardware should be added. If not, it will not be added to reduce the overhead.
ifneq ($(TARGET), hw)
	BC_EXT_CONFIG += -g
	KERNEL_EXT_CONFIG += -g
endif

HLS_IP_FOLDER  = $(shell readlink -f Base_IPs/synthesis_results_HMB)
BC_EXT_CONFIG += --user_ip_repo_paths
BC_EXT_CONFIG += $(HLS_IP_FOLDER)

LINK_EXT_CONFIG += --temp_dir
LINK_EXT_CONFIG += build/vivado

#
# primary build targets
#

.PHONY: all clean host kernel link run kill
all: $(HW_KERNEL_OBJS) $(BINARY_CONTAINER) $(HOST_EXE)
	-@cp $(HOST_EXE) ./
	-@cp $(BINARY_CONTAINER) ./

host: $(HOST_TX_EXE) $(HOST_RX_EXE)
	-@cp $(HOST_TX_EXE) ./
	-@cp $(HOST_RX_EXE) ./


kernel: $(HW_KERNEL_OBJS)


link: $(BINARY_CONTAINER)


run: $(RUN_EXE) $(RUN_BIN) emconfig.json
	export XCL_EMULATION_MODE=$(TARGET) && export XRT_INI_PATH=$(XRT_INI_CONFIG) && ./$(RUN_EXE) $(RUN_BIN)

$(RUN_EXE): $(HOST_EXE)
	-@cp $(HOST_EXE) ./

$(RUN_BIN): $(BINARY_CONTAINER)
	-@cp $(BINARY_CONTAINER) ./

clean:
	-$(RM) $(HW_KERNEL_OBJS) $(BINARY_CONTAINER) *.log *.mdb
	-$(RMDIR) $(BUILD_SUBDIRS)
	-$(RMDIR) .Xil
	-$(RM) *.json
	-$(RM) $(RUN_EXE)
	-$(RM) $(RUN_BIN)
	-$(RMDIR) .run
	-$(RMDIR) .ipcache
	-$(RM) *.wdb
	-$(RM) *.wcfg
	-$(RM) *.protoinst
	-$(RM) *.csv


.PHONY: incremental
incremental: all


nothing:


kill:
	-@./kill_simulation.sh

# build kernels first, automatic build all kernels
$(KERNEL_O_DIR)/%.xo: $(KERNEL_SRC_DIR)/%.cpp $(HW_KERNEL_HEADERS)
	-@mkdir -p $(@D)
	-@mkdir -p $(LOG_DIR)
	-@mkdir -p $(REPORT_DIR)
	-@$(RM) $@
	$(VPP) $(VPP_OPTS) --compile -I"$(<D)" --kernel $(basename $(@F)) --advanced.misc solution_name=$(basename $(@F)) $(KERNEL_EXT_CONFIG) -o"$@" "$<"


# link project secondly
$(BINARY_CONTAINER): $(HW_KERNEL_OBJS) $(HW_COMMON_KERNELS) $(BC_CONFIG)
	-@mkdir -p $(@D)
	$(VPP_LINKER) $(VPP_OPTS) --link --platform $(VITIS_PLATFORM) --config $(BC_CONFIG) $(BC_EXT_CONFIG) --temp_dir build/vivado --log_dir $(LOG_DIR) --report_dir $(REPORT_DIR) -R2 -o"$@" $(HW_KERNEL_OBJS) $(HW_COMMON_KERNELS)


# bulid host finally
$(HOST_TX_EXE): $(HOST_TX_OBJ) $(HOST_COMMON_OBJ)
	-@mkdir -p $(@D)
	$(HOST_CXX) -o "$@" $(^) $(LDFLAGS)

$(HOST_RX_EXE): $(HOST_RX_OBJ) $(HOST_COMMON_OBJ)
	-@mkdir -p $(@D)
	$(HOST_CXX) -o "$@" $(^) $(LDFLAGS)

$(HOST_O_DIR)/%.o: $(HOST_SRC_DIR)/%.cpp
	-@mkdir -p $(@D)
	$(HOST_CXX) $(CXXFLAGS) -o "$@" "$<"

emconfig.json:
	-@emconfigutil --platform $(VITIS_PLATFORM_PATH)

