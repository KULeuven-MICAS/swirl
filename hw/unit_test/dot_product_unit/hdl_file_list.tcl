set HDL_PATH ../../rtl

set HDL_FILES [ list                    \
    "./src/tb_dot_product_unit.sv"                 \
    "${HDL_PATH}/multiplier.sv"              \
    "${HDL_PATH}/libs/bp_pipe.sv"        \
    "${HDL_PATH}/libs/adder.sv"        \
    "${HDL_PATH}/libs/adder_tree_layer.sv"        \
    "${HDL_PATH}/libs/adder_tree.sv"        \
]

set INCLUDE_DIRS [ list                 \
    "${HDL_PATH}/libs/include"          \
    "./src"                             \
]