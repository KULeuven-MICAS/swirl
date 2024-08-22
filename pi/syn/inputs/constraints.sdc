set sdc_version 1.5
set_load_unit -picofarads 1
set_units -time ps

# 100 MHz clock
if {[info exists ::env(CLKPRD)]} {
    set SOC_C_Period $::env(CLKPRD)
} else {
    set SOC_C_Period 10000
}
set SOC_C_Latency_Max                 0
set SOC_C_Latency_Min                 0
set SOC_C_Uncertainty_Setup         500
set SOC_C_Uncertainty_Hold          125
set SOC_C_Transition                500

create_clock -name CLK_IN   -period $SOC_C_Period      [get_ports  clk_i]
set_clock_uncertainty  -setup        $SOC_C_Uncertainty_Setup [get_clocks CLK_IN]
set_clock_uncertainty  -hold         $SOC_C_Uncertainty_Hold [get_clocks CLK_IN]
set_clock_transition                 $SOC_C_Transition  [get_clocks CLK_IN]
set_clock_latency -max               $SOC_C_Latency_Max [get_clocks CLK_IN]
set_clock_latency -min               $SOC_C_Latency_Min [get_clocks CLK_IN]

set_load 0.00001 [all_outputs]