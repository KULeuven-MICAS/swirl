set HDL_PATH ../../rtl

set HDL_FILES [ list                    \
    "./src/tb_adder.sv"                 \
    "${HDL_PATH}/adder.sv"              \
    "${HDL_PATH}/libs/bp_pipe.sv"        \
]

set INCLUDE_DIRS [ list                 \
    "${HDL_PATH}/libs/include"          \
    "./src"                             \
]