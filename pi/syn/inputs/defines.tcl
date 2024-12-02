# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
# Defines default values for synthesis parameters

# DATAW = input precision in bits
if {[info exists ::env(DATAW)]} {
    set DATAW $::env(DATAW)
} else {
    set DATAW 8
}

# M_SIZE = number of rows in the A matrix unit tile
if {[info exists ::env(M_SIZE)]} {
    set M_SIZE $::env(M_SIZE)
} else {
    set M_SIZE 1
}

# N_SIZE = number of columns in the B matrix unit tile
if {[info exists ::env(N_SIZE)]} { 
    set N_SIZE $::env(N_SIZE)
} else {
    set N_SIZE 1
}

# K_SIZE = number of columns in the A matrix and rows in the B matrix unit tiles
if {[info exists ::env(K_SIZE)]} { 
    set K_SIZE $::env(K_SIZE)
} else {
    set K_SIZE 2
}

# PIPE_REGS = number of pipeline stages
if {[info exists ::env(PIPE_REGS)]} { 
    set PIPE_REGS $::env(PIPE_REGS)
} else {
    set PIPE_REGS 1
}

# PIPE_REGS_TREE = number of pipeline stages for tree
if {[info exists ::env(PIPE_REGS_TREE)]} { 
    set PIPE_REGS_TREE $::env(PIPE_REGS_TREE)
} else {
    set PIPE_REGS_TREE 1
}

# PIPE_REGS_MUL = number of pipeline stages
if {[info exists ::env(PIPE_REGS_MUL)]} { 
    set PIPE_REGS_MUL $::env(PIPE_REGS_MUL)
} else {
    set PIPE_REGS_MUL 1
}

# TREE = 1 for tree-based architecture, 0 for chain-based architecture
if {[info exists ::env(TREE)]} { 
    set TREE $::env(TREE)
} else {
    set TREE 1
}

# CLK_SPD = clock period in ps
if {[info exists ::env(CLK_SPD)]} { 
    set CLK_SPD $::env(CLK_SPD)
} else {
    set CLK_SPD 10000
}

# DOTP_ARCH = 0 for base architecture, 1 for partitioned architecture, 2 for sequential architecture
if {[info exists ::env(DOTP_ARCH)]} { 
    set DOTP_ARCH $::env(DOTP_ARCH)
} else {
    set DOTP_ARCH 1
}

# SYN_MODULE = name of the top-level module
if {[info exists ::env(SYN_MODULE)]} { 
    set SYN_MODULE $::env(SYN_MODULE)
} else {
    set SYN_MODULE "syn_tle"
}

# RETIME = 1 to enable retiming, 0 to disable it
if {[info exists ::env(RETIME)]} { 
    set RETIME $::env(RETIME)
} else {
    set RETIME 0
}

# MANUAL_PIPELINE = 1 to enable manual pipeline, 0 to disable it
if {[info exists ::env(MANUAL_PIPELINE)]} { 
    set MANUAL_PIPELINE $::env(MANUAL_PIPELINE)
} else {
    set MANUAL_PIPELINE 0
}

if {[info exists ::env(OUTPUTS_DIR)]} { 
    set OUTPUTS_DIR $::env(OUTPUTS_DIR)
} else {
    set OUTPUTS_DIR $SCRIPT_DIR/outputs/${SYN_MODULE}/A${DOTP_ARCH}_W${DATAW}_M${M_SIZE}_N${N_SIZE}_K${K_SIZE}_PT${PIPE_REGS_TREE}_PM${PIPE_REGS_MUL}_C${CLK_SPD}_RT${RETIME}
}