# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
#          Mats Vanhamel
# This script installs the sky130 PDK

# Clone the sky130 PDK into volume1 as it takes too much space
USER_NAME=$(whoami)
SKY130_PATH=/volume1/users/$USER_NAME/no_backup/130_skywater_pdk

# Clone the sky130 PDK
git clone --recurse-submodules -j8 git@github.com:google/skywater-pdk.git $SKY130_PATH
cd $SKY130_PATH

# Build the PDK
make all

# Build the timing models
make sky130_fd_sc_hs

# Back to the original directory
cd -