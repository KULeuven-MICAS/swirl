# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
# Basic power analysis script for Skywater 130nm

set DESIGN ${SYN_MODULE}

set SCRIPT_DIR [file dirname [info script]]
set PROJECT_DIR    $SCRIPT_DIR/../../
set SIM_PATH       $PROJECT_DIR/sim
set INPUTS_DIR     $SCRIPT_DIR/inputs

source ${INPUTS_DIR}/defines.tcl

source $SCRIPT_DIR/tech/skywater130_setup.tcl
set_db library [list \
    ${SKYWT130_TIMING_HOME}/sky130_fd_sc_hs__tt_025C_1v80.lib \
    ]

set_attribute lef_library ${SKYWT130_LEF_FILES}

read_hdl -netlist ${NETLIST}
elaborate ${DESIGN}
read_saif -instance ${DESIGN} ${ACTIVITY_FILE}

report_power -by_hierarchy -level 4 > ${REPORT_FILE}

exit