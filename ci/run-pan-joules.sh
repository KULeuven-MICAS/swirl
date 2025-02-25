# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Quinten Guelinckx <quinten.guelinckx@student.kuleuven.be>
# run-pan.sh: run power analysis on the generated RTL

set -e

show_usage()
{
    echo "Swirl: Power analysis script"
    echo "Usage: $0 [[--syn_mod=#name] [--netlist=#file] [act-file=#file] [rep-file=#file] [--help]]"
}

show_help()
{
    show_usage
    echo ""
    echo "Options:"
    echo "  --syn_mod=#name: synthesis module name (default: syn_tle_dotp)"
    echo "  --netlist=#file: netlist file (default: ./outputs/syn_tle_dotp.v)"
    echo "  --act-file=#file: activity file (default: ./outputs/syn_tle_dotp.act)"
    echo "  --rep-file=#file: report file (default: ./outputs/syn_tle_dotp.rep)"
    echo "  --help: show this help message"
}

SCRIPT_DIR=$(dirname "$0")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

# Default values
SYN_MODULE="syn_tle_dotp"
NETLIST="$ROOT_DIR/pi/syn/outputs/${SYN_MODULE}/syn_tle_dotp.v"
ACT_FILE="$ROOT_DIR/pi/syn/outputs/${SYN_MODULE}/syn_tle_dotp.saif"
REP_FILE="$ROOT_DIR/pi/syn/outputs/${SYN_MODULE}/syn_tle_dotp.txt"

for i in "$@"
do
case $i in
    --syn_mod=*)
        SYN_MODULE="${i#*=}"
        shift
        ;;
    --netlist=*)
        NETLIST="${i#*=}"
        shift
        ;;
    --act-file=*)
        ACT_FILE="${i#*=}"
        shift
        ;;
    --rep-file=*)
        REP_FILE="${i#*=}"
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

echo "Running power analysis with the following parameters:"
echo "  SYN_MODULE=$SYN_MODULE"
echo "  NETLIST=$NETLIST"
echo "  ACT_FILE=$ACT_FILE"
echo "  REP_FILE=$REP_FILE"

source /esat/micas-data/data/design/scripts/ddi_22.35.rc
SYN_MODULE=$SYN_MODULE NETLIST=$NETLIST ACTIVITY_FILE=$ACT_FILE REPORT_FILE=$REP_FILE genus -legacy_ui -overwrite -files ./pi/power_analysis/pan.tcl -log genCompile.log -lic_startup_options Joules_RTL_Power