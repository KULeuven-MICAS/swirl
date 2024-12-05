set HDL_PATH ../../rtl
set sky_lib_dir ../../../../../../../../volume1/users/r0941589/no_backup/130_skywater_pdk/libraries/sky130_fd_sc_hs/latest/cells/

if {${SYN}} {
    set HDL_FILES [ list                    \
        "../../../../../../../../volume1/users/r0941589/no_backup_open_pdk/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hs/verilog/sky130_fd_sc_hs.v"  \
        "../../../../../../../../volume1/users/r0941589/no_backup_open_pdk/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hs/verilog/primitives.v"  \
        "${SYN_PATH}/syn_tle_dotp.v"       \
        "./src/tb_dot_product_unit.sv"             \
    ]
    set DEFINES "${DEFINES}+FUNCTIONAL"
} else {
    set HDL_FILES [ list                    \
        "./src/tb_dot_product_unit.sv"                 \
        "${HDL_PATH}/multiplier.sv"              \
        "${HDL_PATH}/libs/bp_pipe.sv"        \
        "${HDL_PATH}/adder_tree_layer.sv"        \
        "${HDL_PATH}/adder.sv"        \
        "${HDL_PATH}/adder_tree.sv"        \
        "${HDL_PATH}/dot_product_unit.sv"        \
    ]
}

set INCLUDE_DIRS [ list                 \
    "${HDL_PATH}/libs/include"          \
    "./src"                             \
]