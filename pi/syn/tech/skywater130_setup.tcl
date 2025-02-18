# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
#          Mats Vanhamel
# Skywater 130nm PDK setup script

set USER_NAME [exec whoami]
set SKYWT130_PDK_HOME /volume1/users/$USER_NAME/no_backup_open_pdk/open_pdks/sky130/sky130A

# LEF files
set SKYWT130_LEF_PATH "$SKYWT130_PDK_HOME/libs.ref/sky130_fd_sc_hd/techlef"

set SKYWT130_LEF_FILES [list \
    "$SKYWT130_LEF_PATH/sky130_fd_sc_hd__nom.tlef" \
    ]

set all_lef_files $SKYWT130_LEF_FILES

set SKYWT130_TIMING_HOME "$SKYWT130_PDK_HOME/libs.ref/sky130_fd_sc_hd/lib"