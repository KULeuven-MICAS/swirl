// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>

`ifndef SYNTHESIS

`define ERROR(msg) \
    $error msg

`define ASSERT(cond, msg) \
    assert(cond) else $error msg

`define STATIC_ASSERT(cond, msg) \
    generate                     \
        if (!(cond)) $error msg; \
    endgenerate

`define RUNTIME_ASSERT(cond, msg)     \
    always @(posedge clk) begin       \
        assert(cond) else $error msg; \
    end

`else // SYNTHESIS

`define ERROR(msg)
`define ASSERT(cond, msg) if (cond);
`define STATIC_ASSERT(cond, msg)
`define RUNTIME_ASSERT(cond, msg)

`endif // SYNTHESIS
