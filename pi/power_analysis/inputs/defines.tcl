# Copyright 2024 KU Leuven.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
# Defines default values for power analysis parameters

# SYN_MODULE = name of the top-level module
if {[info exists ::env(SYN_MODULE)]} { 
    set SYN_MODULE $::env(SYN_MODULE)
} else {
    set SYN_MODULE "syn_tle"
}

# NETLIST = path to the synthesized netlist
if {[info exists ::env(NETLIST)]} { 
    set NETLIST $::env(NETLIST)
} else {
    set NETLIST "syn_tle.v"
}

# ACTIVITY_FILE = path to the activity file
if {[info exists ::env(ACTIVITY_FILE)]} { 
    set ACTIVITY_FILE $::env(ACTIVITY_FILE)
} else {
    set ACTIVITY_FILE "syn_tle.saif"
}

# REPORT_FILE = path to the power report file
if {[info exists ::env(REPORT_FILE)]} { 
    set REPORT_FILE $::env(REPORT_FILE)
} else {
    set REPORT_FILE "power_report.txt"
}

# Print the values
puts "SYN_MODULE: $SYN_MODULE"
puts "NETLIST: $NETLIST"
puts "ACTIVITY_FILE: $ACTIVITY_FILE"
puts "REPORT_FILE: $REPORT_FILE"
