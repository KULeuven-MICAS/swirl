# syn.tcl

# Set default values for parameters
if {![info exists ::env(P)]} { set ::env(P) 8 }
if {![info exists ::env(M)]} { set ::env(M) 1 }
if {![info exists ::env(N)]} { set ::env(N) 1 }
if {![info exists ::env(K)]} { set ::env(K) 2 }
if {![info exists ::env(PIPESTAGES)]} { set ::env(PIPESTAGES) 1 }
if {![info exists ::env(TREE)]} { set ::env(TREE) 1 }
if {![info exists ::env(CLKSPD)]} { set ::env(CLKSPD) 200 }

# Assign parameters from environment variables
set P $::env(P)
set M $::env(M)
set N $::env(N)
set K $::env(K)
set PIPESTAGES $::env(PIPESTAGES)
set TREE $::env(TREE)
set CLKSPD $::env(CLKSPD)

# Debugging: Print parameter values
puts "Parameters: P=$P, M=$M, N=$N, K=$K, PIPESTAGES=$PIPESTAGES, TREE=$TREE, CLKSPD=$CLKSPD"

# Rest of your synthesis script...