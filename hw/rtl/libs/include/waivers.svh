// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>

`ifdef VERILATOR

`define TRACING_ON      /* verilator tracing_on */
`define TRACING_OFF     /* verilator tracing_off */
`ifndef NDEBUG
    `define DEBUG_BLOCK(x) /* verilator lint_off UNUSED */ \
                           x \
                           /* verilator lint_on UNUSED */
`else
    `define DEBUG_BLOCK(x)
`endif

`define IGNORE_UNOPTFLAT_BEGIN /* verilator lint_off UNOPTFLAT */

`define IGNORE_UNOPTFLAT_END  /* verilator lint_off UNOPTFLAT */

`define IGNORE_UNUSED_BEGIN   /* verilator lint_off UNUSED */

`define IGNORE_UNUSED_END     /* verilator lint_on UNUSED */

`define IGNORE_WARNINGS_BEGIN /* verilator lint_off UNUSED */ \
                              /* verilator lint_off PINCONNECTEMPTY */ \
                              /* verilator lint_off WIDTH */ \
                              /* verilator lint_off UNOPTFLAT */ \
                              /* verilator lint_off UNDRIVEN */ \
                              /* verilator lint_off DECLFILENAME */ \
                              /* verilator lint_off IMPLICIT */ \
                              /* verilator lint_off PINMISSING */ \
                              /* verilator lint_off IMPORTSTAR */ \
                              /* verilator lint_off UNSIGNED */ \
                              /* verilator lint_off SYMRSVDWORD */

`define IGNORE_WARNINGS_END   /* verilator lint_on UNUSED */ \
                              /* verilator lint_on PINCONNECTEMPTY */ \
                              /* verilator lint_on WIDTH */ \
                              /* verilator lint_on UNOPTFLAT */ \
                              /* verilator lint_on UNDRIVEN */ \
                              /* verilator lint_on DECLFILENAME */ \
                              /* verilator lint_on IMPLICIT */ \
                              /* verilator lint_off PINMISSING */ \
                              /* verilator lint_on IMPORTSTAR */ \
                              /* verilator lint_on UNSIGNED */ \
                              /* verilator lint_on SYMRSVDWORD */

`define UNUSED_PARAM(x)  /* verilator lint_off UNUSED */ \
                         localparam  __``x = x; \
                         /* verilator lint_on UNUSED */

`define UNUSED_SPARAM(x) /* verilator lint_off UNUSED */ \
                         localparam `STRING __``x = x; \
                         /* verilator lint_on UNUSED */

`define UNUSED_VAR(x)   if (1) begin \
                            /* verilator lint_off UNUSED */ \
                            wire [$bits(x)-1:0] __x = x; \
                            /* verilator lint_on UNUSED */ \
                        end

`define UNUSED_PIN(x)   /* verilator lint_off PINCONNECTEMPTY */ \
                        . x () \
                        /* verilator lint_on PINCONNECTEMPTY */
`define UNUSED_ARG(x)   /* verilator lint_off UNUSED */ \
                        x \
                        /* verilator lint_on UNUSED */

`else // !VERILATOR

`define TRACING_ON
`define TRACING_OFF
`ifndef NDEBUG
    `define DEBUG_BLOCK(x) x
`else
    `define DEBUG_BLOCK(x)
`endif
`define IGNORE_UNOPTFLAT_BEGIN
`define IGNORE_UNOPTFLAT_END
`define IGNORE_UNUSED_BEGIN
`define IGNORE_UNUSED_END
`define IGNORE_WARNINGS_BEGIN
`define IGNORE_WARNINGS_END
`define UNUSED_PARAM(x)
`define UNUSED_SPARAM(x)
`define UNUSED_VAR(x)
`define UNUSED_PIN(x) . x ()
`define UNUSED_ARG(x) x

`endif // VERILATOR
