PROJECT_ROOT = $(realpath ../../../)

# PATHS
SIM_DIR = $(PROJECT_ROOT)/sim
VSIM_SCRIPT = $(SIM_DIR)/questasim/sim-run.tcl

SIM_NAME ?= $(shell basename $(CURDIR))
TEST_PATH ?= $(CURDIR)
DBG ?= 0
NO_GUI ?= 1
FORCE_BUILD ?= 1
DEFINES ?=

# VSIM FLAGS
ifeq ($(NO_GUI), 1)
	VSIM_FLAGS += -c
endif

questa-run:
	@mkdir -p ./work
	TEST_PATH=$(TEST_PATH) SIM_NAME=$(SIM_NAME) DBG=$(DBG) \
	FORCE_BUILD=$(FORCE_BUILD) DEFINES=$(DEFINES) \
	vsim $(VSIM_FLAGS) -do "source $(VSIM_SCRIPT)" 