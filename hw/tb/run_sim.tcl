if { [info exists ::env(TREE)] } {
    set TREE $::env(TREE)
} else {
    set TREE 0
}
if { [info exists ::env(CONFIGURABLE)] } {
    set CONFIGURABLE $::env(CONFIGURABLE)
} else {
    set CONFIGURABLE 0
}
if { [info exists ::env(MULT_TB)] } {
    set MULT_TB $::env(MULT_TB)
} else {
    set MULT_TB 0
}
if { [info exists ::env(PY)] } {
    set PY $::env(PY)
} else { 
    set PY 0
}
if { [info exists ::env(SIMNAME)] } {
    set SIMNAME $::env(SIMNAME)
} else {
    puts "NO SIMNAME DEFINED"
}
if {[info exists ::env(NO_GUI)]} {
    set NO_GUI [expr {$::env(NO_GUI) == 1}]
} else {
    set NO_GUI 0
}

# Run Python script to generate test data
if {$PY == 1} {
    exec python3 tb_${SIMNAME}.py
}


# Set library directory
set WLIB "./work/work_${SIMNAME}"
vlib ${WLIB}
vmap work ${WLIB}
vmap work_lib ${WLIB}

# Set hardware directory to the current directory
set HDL_PATH "./../rtl"

# Compile HDL files
vlog -sv -quiet -work ${WLIB} ${HDL_PATH}/*.sv ./*sv


# Define testbench configurations with parameters
if {$MULT_TB ==  1} {
    set TESTBENCHES {
    "2x2x2" 2 2 2
    "8x4x16" 8 4 16
}
} else {
    set TESTBENCHES {
    0 0 0 0
    }
}


# Run simulation for each testbench
foreach {TB M N K} $TESTBENCHES {
    # Compile the testbench with specific parameters
    if {$MULT_TB == 1} {
        vlog -sv -quiet -work ${WLIB} +define+M=${M} +define+N=${N} +define+K=${K} +define+TREE=${TREE} +define+CONFIGURABLE=${CONFIGURABLE} ./tb_${SIMNAME}.sv
    } else {
        vlog -sv -work ${WLIB} ${HDL_PATH}/*.sv
    }
    

    # Optimization and object preparation
    if {$NO_GUI == 0} {
        vopt -quiet -work ${WLIB} +acc tb_${SIMNAME} -o dbg_${TB}
        set OBJ "dbg_${TB}"
    } else {
        vopt -quiet -work ${WLIB} tb_${SIMNAME} -o nodbg_${TB}
        set OBJ "nodbg_${TB}"
    }

    # Verify library mapping
    vmap

    # Apply the IterationLimit attribute
    set IterationLimit 200000

    # Run the simulation
    vsim \
      -quiet \
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
