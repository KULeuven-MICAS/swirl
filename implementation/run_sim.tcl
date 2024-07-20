# To run hardware simulation: 'vsim -c -do run_sim.tcl'

quietly set SIMNAME "rtl"

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


if {${NO_GUI} == 0} {
  vopt -work ${WLIB} +acc tb_ -o dbg 
  set OBJ "dbg"
} else {
  vopt -work ${WLIB} tb_ -o nodbg 
  set OBJ "nodbg"
}

# Verify library mapping
vmap


vsim \
  -wlf work/${SIMNAME}.wlf \
  -msgmode both -displaymsgmode both \
  -L work_lib  \
  -work ${WLIB} \
  ${OBJ}

# Run the simulation for a specified time (e.g., 50ns)
run 200ns

# Exit the simulation
quit
