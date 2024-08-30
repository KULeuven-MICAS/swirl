#!/bin/sh

# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
# run-syn.sh: run synthesis on the generated RTL

set -e

show_usage()
{
    echo "Swirl: Synthesis script"
    echo "Usage: $0 [[--dataw=#n] [--M_size=#n] [--N_size=#n] [--K_size=#n] [--pipe=#n] [--tree] [--clk_period=#n] [--arch=#code] [--output_dir=#path] [--help]]"
}

show_help()
{
    show_usage
    echo ""
    echo "Options:"
    echo "  --dataw=#n: data width in bits (default: 8)"
    echo "  --M_size=#n: number of rows in the matrix (default: 1)"
    echo "  --N_size=#n: number of columns in the matrix (default: 1)"
    echo "  --K_size=#n: number of columns in the matrix (default: 2)"
    echo "  --pipe=#n: pipeline depth (default: 1)"
    echo "  --tree: use tree-based architecture (default: 1)"
    echo "  --clk_period=#n: target clock period in ps (default: 10000)"
    echo "  --arch=#name: 0: baseline, 1: partitioned, 2: sequential (default: 1)"
    echo "  --output_dir=#path: output directory (default: ./outputs/)"
    echo "  --help: show this help message"
}

SCRIPT_DIR=$(dirname "$0")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

# Default values
DATAW=8
M_SIZE=1
N_SIZE=1
K_SIZE=2
PIPE_REGS=0
TREE=1
CLK_SPD=10000
DOTP_ARCH=2
SYN_MODULE="syn_tle"
RETIME=0
MANUAL_PIPELINE=0
OUTPUT_DIR=

for i in "$@"
do
case $i in
    --dataw=*)
        DATAW="${i#*=}"
        shift
        ;;
    --M_size=*)
        M_SIZE="${i#*=}"
        shift
        ;;
    --N_size=*)
        N_SIZE="${i#*=}"
        shift
        ;;
    --K_size=*)
        K_SIZE="${i#*=}"
        shift
        ;;
    --pipe=*)
        PIPE_REGS="${i#*=}"
        shift
        ;;
    --tree)
        TREE=1
        shift
        ;;
    --clk_period=*)
        CLK_SPD="${i#*=}"
        shift
        ;;
    --arch=*)
        DOTP_ARCH="${i#*=}"
        shift
        ;;
    --syn_module=*)
        SYN_MODULE="${i#*=}"
        shift
        ;;
    --output_dir=*)
        OUTPUT_DIR="${i#*=}"
        shift
        ;;
    --retime)
        RETIME=1
        shift
        ;;
    --manual_pipeline)
        MANUAL_PIPELINE=1
        shift
        ;;
    --help)
        show_help
        exit 0
        ;;
    *)
        echo "Invalid option: $i"
        show_usage
        exit -1
        ;;
esac
done

if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="$ROOT_DIR/pi/syn/outputs/${SYN_MODULE}/A${DOTP_ARCH}_W${DATAW}_M${M_SIZE}_N${N_SIZE}_K${K_SIZE}_P${PIPE_REGS}_T${TREE}_C${CLK_SPD}_RT${RETIME}_MP${MANUAL_PIPELINE}"
fi

echo "Running synthesis with the following parameters:"
echo "  SYN_MODULE=$SYN_MODULE"
echo "  DATAW=$DATAW"
echo "  M_SIZE=$M_SIZE"
echo "  N_SIZE=$N_SIZE"
echo "  K_SIZE=$K_SIZE"
echo "  PIPE_REGS=$PIPE_REGS"
echo "  TREE=$TREE"
echo "  CLK_SPD=$CLK_SPD"
echo "  DOTP_ARCH=$DOTP_ARCH"
echo "  RETIME=$RETIME"
echo "  MANUAL_PIPELINE=$MANUAL_PIPELINE"
echo "  OUTPUT_DIR=$OUTPUT_DIR"

cd "$ROOT_DIR/pi/syn"
mkdir -p ./work
cd ./work


source /esat/micas-data/data/design/scripts/ddi_22.35.rc
M_SIZE=$M_SIZE N_SIZE=$N_SIZE K_SIZE=$K_SIZE PIPE_REGS=$PIPE_REGS TREE=$TREE CLK_SPD=$CLK_SPD DOTP_ARCH=$DOTP_ARCH OUTPUT_DIR=$OUTPUT_DIR SYN_MODULE=$SYN_MODULE RETIME=$RETIME MANUAL_PIPELINE=$MANUAL_PIPELINE genus -legacy_ui -overwrite -files ../syn.tcl -log genCompile.log