#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 11.0 Build 208 07/03/2011 Service Pack 1 SJ Full Version
#
#************************************************************

# Copyright (C) 1991-2011 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints
create_clock -name "clock_50" -period 20.000ns [get_ports {clock_50}]

# Create the associated virtual input clock
#create_clock -period 20.000ns -name virt_clk50

# Create default clock
derive_clocks -period 20.000ns

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# tsu
set_max_delay -from [all_inputs] -to [get_registers *] 5.000ns

# tco
set_max_delay -from [get_registers *] -to [all_outputs] 15.000ns

#tpd
set_max_delay -from [all_inputs] -to [all_outputs] 15.000ns

# th
#set_input_delay -clock virt_clk50 -min -1.5ns [all_inputs]

# tco constraints
#set_output_delay -clock "clock_50" -max 18ns [get_ports {*}] 
#set_output_delay -clock "clock_50" -min -1.000ns [get_ports {*}] 


# tpd constraints
#set_max_delay 20.000ns -from [get_ports {*}] -to [get_ports {*}]
#set_min_delay 1.000ns -from [get_ports {*}] -to [get_ports {*}]

# Remove async reset checking
set_false_path -from [get_registers {gene_reset:gene_reset|count[15]}] -to [get_registers *]

