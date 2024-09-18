# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

source ${INPUTS_DIR}/arch_hdl_list/common_hdl_list.tcl
lappend HDL_LIST ${HDL_PATH}/generic_mux.sv
lappend HDL_LIST ${HDL_PATH}/mult_2bit.sv
lappend HDL_LIST ${HDL_PATH}/binary_tree_adder.sv
lappend HDL_LIST ${HDL_PATH}/adder_tree_layer.sv
lappend HDL_LIST ${HDL_PATH}/binary_tree_adder_unsigned.sv
lappend HDL_LIST ${HDL_PATH}/adder_tree_layer_unsigned.sv
lappend HDL_LIST ${HDL_PATH}/seq_mult.sv
lappend HDL_LIST ${HDL_PATH}/seq_MAC.sv
lappend HDL_LIST ${HDL_PATH}/half_adder.sv
lappend HDL_LIST ${HDL_PATH}/full_adder.sv
lappend HDL_LIST ${HDL_PATH}/programmable_counter.sv