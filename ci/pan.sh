#!/bin/bash

# List of module names to iterate over
MODULE_NAMES=("A1_W8_M1_N1_K8_PT5_PM1_C1666_RT1") # Add more names as needed

# Power file number
POWER_NUM=80

# Set variables for file paths
TB_FILE="./hw/unit_test/dot_product_unit/src/tb_dot_product_unit.sv"
PRIM_LIB="./../../../../volume1/users/r0941589/no_backup_open_pdk/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
STD_LIB="./../../../../volume1/users/r0941589/no_backup_open_pdk/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"

# Loop through each module name
for MODULE in "${MODULE_NAMES[@]}"; do
    SYN_NETLIST="./pi/syn/outputs/syn_tle_dotp/${MODULE}/syn_tle_dotp.v"
    
    # Compilation step
    xrun -compile +access+r "$TB_FILE" "$SYN_NETLIST" "$PRIM_LIB" "$STD_LIB" > "comp_${MODULE}.log"
    echo "Compilation for $MODULE completed. Check comp_${MODULE}.log for details."
    
    # Elaboration step
    xrun -elaborate +access+r "$TB_FILE" "$SYN_NETLIST" "$PRIM_LIB" "$STD_LIB" >> "comp_${MODULE}.log"
    echo "Elaboration for $MODULE completed. Check comp_${MODULE}.log for details."
    
    # Running simulation
    xrun -R -input ./hw/unit_test/dot_product_unit/run-tb.tcl
    echo "Simulation for $MODULE completed."
    
    # Running additional script
    ./ci/run-pan.sh --syn_mod="$MODULE" --netlist=syn_tle_dotp --act-file=tb_dot_product_unit --rep-file="power_${POWER_NUM}.txt"
    echo "run-pan.sh executed successfully for $MODULE."
done
