# Default value for the TREE variable
set TREE 0

# Access the TREE variable from the environment if available
if { [info exists ::env(TREE)] } {
    set TREE $::env(TREE)
}

# Output the status of TREE for debugging purposes
puts "TREE is set to $TREE"

# Run Python script to generate test data
exec python3 tb_matmul.py

# Set simulation name
set SIMNAME "matmul"

# Check for NO_GUI environment variable
if {[info exists ::env(NO_GUI)]} {
    set NO_GUI [expr {$::env(NO_GUI) == 1}]
} else {
    set NO_GUI 0
}

# Set library directory
set WLIB "./work/work_${SIMNAME}"
vlib ${WLIB}
vmap work ${WLIB}
vmap work_lib ${WLIB}

# Set hardware directory to the current directory
set HDL_PATH "./HDL_files"

# Compile HDL files
vlog -sv -work ${WLIB} ${HDL_PATH}/*.sv

# Define testbench configurations with parameters
set TESTBENCHES {
    "2x2x2" 2 2 2
    "8x4x16" 8 4 16
}

# Run simulation for each testbench
foreach {TB M N K} $TESTBENCHES {
    # Compile the testbench with specific parameters
    vlog -sv -work ${WLIB} +define+M=${M} +define+N=${N} +define+K=${K} +define+TREE=${TREE} ${HDL_PATH}/tb_${SIMNAME}.sv

    # Optimization and object preparation
    if {$NO_GUI == 0} {
        vopt -work ${WLIB} +acc tb_${SIMNAME} -o dbg_${TB}
        set OBJ "dbg_${TB}"
    } else {
        vopt -work ${WLIB} tb_${SIMNAME} -o nodbg_${TB}
        set OBJ "nodbg_${TB}"
    }

    # Verify library mapping
    vmap

    # Apply the IterationLimit attribute
    set IterationLimit 200000

    # Run the simulation
    vsim \
      -wlf work/${SIMNAME}.wlf \
      -msgmode both -displaymsgmode both \
      -L work_lib  \
      -work ${WLIB} \
      -modelsimini ./modelsim.ini \
      ${OBJ}

    # Run the simulation for a specified time (e.g., 1000ns)
    run 1000ns
}

quit
