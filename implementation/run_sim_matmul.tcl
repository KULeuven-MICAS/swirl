# Run Python script to generate test data
exec python3 tb_matmul.py

# To run hardware simulation: 'vsim -c -do run_sim_matmul.tcl'

quietly set SIMNAME "matmul"

# Check for NO_GUI environment variable
if { [info exist ::env(NO_GUI)] } {
  quietly set NO_GUI $::env(NO_GUI)
} else {
  quietly set NO_GUI 0
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

# Define testbench configurations
set TESTBENCHES {
  "2x2x2"
  "8x4x16"
}

# Run simulation for each testbench
foreach TB ${TESTBENCHES} {
    if {${NO_GUI} == 0} {
        vopt -work ${WLIB} +acc tb_${SIMNAME}_${TB} -o dbg_${TB}
        set OBJ "dbg_${TB}"
    } else {
        vopt -work ${WLIB} tb_${SIMNAME}_${TB} -o nodbg_${TB}
        set OBJ "nodbg_${TB}"
    }

    # Verify library mapping
    vmap

    # Apply the IterationLimit attribute
    set IterationLimit 200000

    vsim \
      -wlf work/${SIMNAME}_${TB}.wlf \
      -msgmode both -displaymsgmode both \
      -L work_lib  \
      -work ${WLIB} \
      -modelsimini ./modelsim.ini \
      ${OBJ}

    # Run the simulation for a specified time (e.g., 200ns)
    run 1000ns
}

quit
