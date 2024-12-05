# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Quinten Guelinckx <quinten.guelinckx@student.kuleuven.be>
#
# This script installs the sky130 PDK with all the verilog code of the modules in one big file for simulation purposes

# create a root directory that will contain all PDK files and supporting tools (install size is ~42GB)
USER_NAME=$(whoami)
export PREFIX=/volume1/users/$USER_NAME/no_backup_open_pdk/
mkdir -p $PREFIX
cd $PREFIX

# install magic via conda, required for open_pdks
conda create -y -c litex-hub --prefix $PREFIX/.conda-signoff magic
export PATH=$PREFIX/.conda-signoff/bin:$PATH

# clone required repos
git clone https://github.com/google/skywater-pdk.git
git clone https://github.com/RTimothyEdwards/open_pdks.git

# install Sky130 PDK via Open-PDKs
#    we disable some install steps to save time
cd $PREFIX/open_pdks
./configure \
    --enable-sky130-pdk=${PREFIX}/skywater-pdk/libraries --prefix=$PREFIX \
    --disable-gf180mcu-pdk --disable-alpha-sky130 --disable-xschem-sky130 --disable-primitive-gf180mcu \
    --disable-verification-gf180mcu --disable-io-gf180mcu --disable-sc-7t5v0-gf180mcu \
    --disable-sc-9t5v0-gf180mcu --disable-sram-gf180mcu --disable-osu-sc-gf180mcu \
    --enable-primitive-sky130 --disable-io-sky130 --disable-sc-ms-sky130 \
    --disable-sc-ls-sky130 --disable-sc-lp-sky130 --enable-sc-hd-sky130 --disable-sc-hdll-sky130 \
    --disable-sc-hvl-sky130
    
make
make install