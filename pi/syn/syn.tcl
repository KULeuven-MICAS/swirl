# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
#          Mats Vanhamel
# Basic synthesis script

set_attribute information_level 2
# Set default values for parameters
if {![info exists ::env(P)]} { set ::env(P) 8 }
if {![info exists ::env(M)]} { set ::env(M) 1 }
if {![info exists ::env(N)]} { set ::env(N) 1 }
if {![info exists ::env(K)]} { set ::env(K) 2 }
if {![info exists ::env(PIPESTAGES)]} { set ::env(PIPESTAGES) 1 }
if {![info exists ::env(TREE)]} { set ::env(TREE) 1 }
if {![info exists ::env(CLKSPD)]} { set ::env(CLKSPD) 200 }
if {![info exists ::env(CONFIGURABLE)]} { set ::env(CONFIGURABLE) 1 }

# Assign parameters from environment variables
set P $::env(P)
set M $::env(M)
set N $::env(N)
set K $::env(K)
set PIPESTAGES $::env(PIPESTAGES)
set TREE $::env(TREE)
set CLKSPD $::env(CLKSPD)
set CONFIGURABLE $::env(CONFIGURABLE)

set DESIGN syn_tle
set PROJECT_DIR    ../../
set INPUTS_DIR  ./inputs
if {$CONFIGURABLE==1} {
    set OUTPUTS_DIR ./../outputs/outputs_partitioned/output_${P}Bit_${M}x${N}x${K}_${CLKSPD}MHz_${PIPESTAGES}PIPES_TREE=${TREE}_CONFIGURABLE
} else {
    set OUTPUTS_DIR ./../outputs/outputs_base/output_${P}Bit_${M}x${N}x${K}_${CLKSPD}MHz_${PIPESTAGES}PIPES_TREE=${TREE}
}

set HDL_PATH [ list \
    $PROJECT_DIR/hw/rtl \
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
    ${HDL_PATH}/binary_tree_adder.sv \
    ${HDL_PATH}/bitwise_add.sv \
    ${HDL_PATH}/config_adder.sv \
    ${HDL_PATH}/config_binary_tree_adder.sv \
    ${HDL_PATH}/config_multiplier_8bit.sv \
    ${HDL_PATH}/config_shiftadder_4bit.sv \
    ${HDL_PATH}/matrix_flattener.sv \
    ${HDL_PATH}/matrix_multiplication_accumulation.sv \
    ${HDL_PATH}/VX_pipe_buffer.sv \
    ${HDL_PATH}/VX_pipe_register.sv \
    ]
read_hdl -sv -define M=${M} -define N=${N} -define K=${K} -define P=${P} -define PIPESTAGES=${PIPESTAGES} -define TREE=${TREE} -define CONFIGURABLE=${CONFIGURABLE} ${HDL_PATH}/syn_tle.sv

elaborate ${DESIGN}
check_design -unresolved
set_attribute retime true matrix_multiplication_accumulation*
set_attribute retime true matrix_multiplication_accumulation/*
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