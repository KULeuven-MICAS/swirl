# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

source ${INPUTS_DIR}/arch_hdl_list/common_hdl_list.tcl
lappend HDL_LIST ${HDL_PATH}/binary_tree_adder.sv
lappend HDL_LIST ${HDL_PATH}/binary_tree_adder_layer.sv