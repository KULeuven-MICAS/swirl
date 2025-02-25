# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
# Basic power analysis script for Skywater 130nm


set SCRIPT_DIR [file dirname [info script]]
set PROJECT_DIR    $SCRIPT_DIR/../..
set SIM_PATH       $PROJECT_DIR/sim
set INPUTS_DIR     $SCRIPT_DIR/inputs
set VCD_DIR        $PROJECT_DIR/hw/unit_test/dot_product_unit

source ${INPUTS_DIR}/defines.tcl

set DESIGN ${SYN_MODULE}
set HDL_PATH       $PROJECT_DIR/pi/syn/outputs/syn_tle_dotp/${SYN_MODULE}

source $SCRIPT_DIR/../syn/tech/sky130_open_pdks_setup.tcl
set_db library [list \
    ${SKYWT130_TIMING_HOME}/sky130_fd_sc_hd__tt_025C_1v80.lib \
    ]

set_db lef_library ${SKYWT130_LEF_FILES}
set_attribute init_hdl_search_path $HDL_PATH

read_power_intent -module ${NETLIST} $SCRIPT_DIR/../syn/tech/power_intent.upf
apply_power_intent
commit_power_intent

read_hdl -netlist ${NETLIST}.v
elaborate ${NETLIST}

set vcd_file ${ACTIVITY_FILE}.vcd
puts "setting vcd_file to ${vcd_file}"
set saif_file ${ACTIVITY_FILE}.saif
puts "setting saif_file to ${saif_file}"
set top_instance ${ACTIVITY_FILE}
puts "setting top_instance to ${top_instance}"

read_vcd ${VCD_DIR}/vcd_file

#read_saif -instance ${NETLIST} ${VCD_DIR}/${saif_file}

#report_power -by_hierarchy -level 4 > ${HDL_PATH}/${REPORT_FILE}

#exit