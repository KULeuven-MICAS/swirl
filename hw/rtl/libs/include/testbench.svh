
`ifndef DBG_MSG
`define DBG_MSG 1
`endif

`ifndef DBG_LVL
`define DBG_LVL 0
`endif

`define STRINGIFY(__x) `"__x`"

`ifdef QUESTA
`define DUMP_VARS(__tle)                              \
    $dumpfile({"waves_", `STRINGIFY(__tle), ".vcd"}); \
    $dumpvars(`DBG_LVL, __tle);                     \

`endif // QUESTA
