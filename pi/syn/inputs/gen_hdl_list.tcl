# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set HDL_LIST_DIR ${INPUTS_DIR}/arch_hdl_list/

if { ${DOTP_ARCH} == 0 } {
    source ${HDL_LIST_DIR}/base_arch_hdl_list.tcl
} elseif { ${DOTP_ARCH} == 1 } {
    source ${HDL_LIST_DIR}/part_arch_hdl_list.tcl
} elseif { ${DOTP_ARCH} == 2 } {
    source ${HDL_LIST_DIR}/seq_arch_hdl_list.tcl
} else {
    puts "Invalid architecture specified"
    exit 1
}