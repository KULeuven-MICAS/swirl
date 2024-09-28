
`ifndef DEBUG_LVL
`define DEBUG_LVL 1
`endif

`define STRINGIFY(__x) `"__x`"

`ifdef QUESTA
`define DUMP_VARS(__tle)                            \
    $dumpfile({"waves_", `STRINGIFY(__tle), ".vcd"}); \
    $dumpvars(`DEBUG_LVL, __tle);                   \

`endif // QUESTA
