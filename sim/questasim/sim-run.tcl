# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
# Basic build script for QuestaSim

set SCRIPT_DIR [file dirname [info script]]

source ${SCRIPT_DIR}/defines.tcl

if {$FORCE_BUILD == 1} {
    puts "Building ..."
    source ${SCRIPT_DIR}/build.tcl
}

# Verify library mapping
vmap

# Apply the IterationLimit attribute
set IterationLimit 200000

# Run simulation
vsim -quiet \
     -wlf work/${SIM_NAME}.wlf \
     -msgmode both -displaymsgmode both \
     -L work_lib  \
     -work ${WLIB} \
     -modelsimini ./modelsim.ini \
     ${OBJ}

run -all
quit