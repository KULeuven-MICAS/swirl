# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
#          Mats Vanhamel
# Basic synthesis script

set_attribute information_level 2\

set P 8
set M 8
set N 4
set K 16
set PIPESTAGES 1
set TREE 1
# CHANGE CLOCKSPEED IN constraints.sdc !
# In MHz
set CLKSPD 100 


set DESIGN syn_tle
set PROJECT_DIR    ../../
set INPUTS_DIR  ./inputs
set OUTPUTS_DIR ./outputs

set HDL_PATH [ list \
    $PROJECT_DIR/implementation/HDL_files \
]

#Add other paths here

set search_path [ join "$HDL_PATH" ]

#if multiple IPs are used, add them to the list
#set search_path [ join "$HDL_PATH 
#                        $IPS_PATH" ]

set reAnalyzeRTL "TRUE"

source tech/skywater130_setup.tcl

set_db library [list \
    ${SKYWT130_TIMING_HOME}/sky130_fd_sc_hs__tt_025C_1v80.lib \
    ]

set_attribute auto_ungroup none /
set_attribute hdl_bidirectional_assign false /
set_attribute hdl_undriven_signal_value 0 /

## Set up low-power flow variables
set_attribute lp_insert_clock_gating true /
set_attribute lp_clock_gating_prefix lowp_cg /

set_attribute leakage_power_effort medium /
set_attribute lp_power_analysis_effort medium /

set_attribute hdl_generate_separator _
set_attribute hdl_generate_index_style "%s_%d"

## Set up allowing const_value for inout to PAD RETC
set_attribute hdl_allow_inout_const_port_connect true /

set_attribute lef_library ${SKYWT130_LEF_FILES}
set_attribute interconnect_mode ple

set_attribute init_hdl_search_path $HDL_PATH /
set_attr hdl_search_path $search_path /


read_hdl -sv [ list \
    ${HDL_PATH}/bitwise_add.sv \
    ${HDL_PATH}/matrix_multiplication_accumulation.sv \
    ${HDL_PATH}/binary_tree_adder.sv \
    ${HDL_PATH}/VX_pipe_buffer.sv \
    ${HDL_PATH}/VX_pipe_register.sv \
    ]
read_hdl -sv -define M=${M} -define N=${N} -define K=${K} -define P=${P} -define PIPESTAGES=${PIPESTAGES} -define TREE=${TREE} ${HDL_PATH}/syn_tle.sv

elaborate ${DESIGN}
check_design -unresolved
set_attribute retime true ${DESIGN}
read_sdc ${INPUTS_DIR}/constraints.sdc

apply_power_intent

set_attribute syn_generic_effort medium
set_attribute syn_map_effort     medium
set_attribute syn_opt_effort     medium

syn_generic ${DESIGN}
report timing -lint

syn_map ${DESIGN}
syn_opt

check_timing_intent

report timing                       > ${OUTPUTS_DIR}/${DESIGN}_timing.rpt
report timing -summary              > ${OUTPUTS_DIR}/${DESIGN}_timing_summary.rpt
report area                         > ${OUTPUTS_DIR}/${DESIGN}_area.rpt
report datapath                     > ${OUTPUTS_DIR}/${DESIGN}_datapath_incr.rpt
report messages                     > ${OUTPUTS_DIR}/${DESIGN}_messages.rpt
report gates                        > ${OUTPUTS_DIR}/${DESIGN}_gates.rpt
report power                        > ${OUTPUTS_DIR}/${DESIGN}_power.rpt
report disabled_transparent_latches > ${OUTPUTS_DIR}/${DESIGN}_latches.rpt

write_hdl > ${OUTPUTS_DIR}/${DESIGN}.v

exit