tb_adder:
	source ~micasusr/design/scripts/questasim_2022.4.rc
	SIMNAME=adder \
	vsim -c -do run_sim.tcl
tb_matmul_tree:
	source ~micasusr/design/scripts/questasim_2022.4.rc
	SIMNAME=matmul \
	TREE=1 \
	MULT_TB=1 \
	PY=1 \
	vsim -c -do run_sim.tcl
tb_syn_tle_tree:
	source ~micasusr/design/scripts/questasim_2022.4.rc
	SIMNAME=syn_tle \
	TREE=1 \
	MULT_TB=1 \
	PY=0 \
	vsim -c -do run_sim.tcl
tb_tree_adder:
	source ~micasusr/design/scripts/questasim_2022.4.rc
	SIMNAME=tree_adder \
	vsim -c -do run_sim.tcl
