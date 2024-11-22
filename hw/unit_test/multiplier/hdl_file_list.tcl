set HDL_PATH ../../rtl

set HDL_FILES [ list                    \
    "./src/tb_multiplier.sv"                 \
    "${HDL_PATH}/multiplier.sv"              \
    "${HDL_PATH}/libs/bp_pipe.sv"        \
]

set INCLUDE_DIRS [ list                 \
    "${HDL_PATH}/libs/include"          \
    "./src"                             \
]