# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

source ${INPUTS_DIR}/arch_hdl_list/common_hdl_list.tcl
lappend HDL_LIST ${HDL_PATH}/config_adder.sv
lappend HDL_LIST ${HDL_PATH}/config_multiplier_4bit.sv
lappend HDL_LIST ${HDL_PATH}/config_binary_tree_adder.sv
lappend HDL_LIST ${HDL_PATH}/config_adder_tree_layer.sv
lappend HDL_LIST ${HDL_PATH}/config_multiplier_8bit.sv
lappend HDL_LIST ${HDL_PATH}/mult_2bit.sv
