# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
#          Mats Vanhamel
# Skywater 130nm PDK setup script

set USER_NAME [exec whoami]
set SKYWT130_PDK_HOME /volume1/users/$USER_NAME/no_backup/130_skywater_pdk

# LEF files
set SKYWT130_LEF_PATH "$SKYWT130_PDK_HOME/libraries/sky130_fd_sc_hs/latest/tech"

set SKYWT130_LEF_FILES [list \
    "$SKYWT130_LEF_PATH/sky130_fd_sc_hs.tlef" \
    ]

set all_lef_files $SKYWT130_LEF_FILES

set SKYWT130_TIMING_HOME "$SKYWT130_PDK_HOME/libraries/sky130_fd_sc_hs/latest/timing"