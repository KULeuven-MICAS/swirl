#!/bin/sh

# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
# run-syn-sweep.sh: Run synthesis with multiple configurations

# Default values for fixed parameters
DATAW=16
M_SIZE=8
N_SIZE=4
K_SIZE=16
TREE=1
DOTP_ARCH=0
RETIME=0
SYN_MODULE="syn_tle"
MANUAL_PIPELINE=0
OUTPUT_DIR=

# Loop over different pipeline depths and clock speeds
for PIPE in 0
do
    for CLK_SPD in 10000
    do

    if [ $RETIME -eq 1 ]
    then
         echo "Sweeping synthesis: PIPE=$PIPE, CLK_SPD=$CLK_SPD with retiming"
        ./ci/run-syn.sh --dataw=$DATAW --M_size=$M_SIZE --N_size=$N_SIZE --K_size=$K_SIZE --pipe=$PIPE --tree --clk_period=$CLK_SPD --arch=$DOTP_ARCH --output_dir="$OUTPUT_DIR" --syn_module="$SYN_MODULE" --retime --manual_pipeline
    else
        echo "Sweeping synthesis: PIPE=$PIPE, CLK_SPD=$CLK_SPD without retiming"
        ./ci/run-syn.sh --dataw=$DATAW --M_size=$M_SIZE --N_size=$N_SIZE --K_size=$K_SIZE --pipe=$PIPE --tree --clk_period=$CLK_SPD --arch=$DOTP_ARCH --output_dir="$OUTPUT_DIR" --syn_module="$SYN_MODULE" --manual_pipeline
    fi
   done
done
