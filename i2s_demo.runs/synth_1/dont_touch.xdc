# This file is automatically generated.
# It contains project source information necessary for synthesis and implementation.

# XDC: C:/Users/danny/OneDrive/Desktop/FPGA/i2s_demo/i2s_demo.xdc

# IP: ip/clk_wiz_0_1/clk_wiz_0.xci
set_property KEEP_HIERARCHY SOFT [get_cells -hier -filter {REF_NAME==clk_wiz_0 || ORIG_REF_NAME==clk_wiz_0} -quiet] -quiet

# XDC: c:/Users/danny/OneDrive/Desktop/FPGA/i2s_demo/i2s_demo.gen/sources_1/ip/clk_wiz_0_1/clk_wiz_0_board.xdc
set_property KEEP_HIERARCHY SOFT [get_cells [split [join [get_cells -hier -filter {REF_NAME==clk_wiz_0 || ORIG_REF_NAME==clk_wiz_0} -quiet] {/inst } ]/inst ] -quiet] -quiet

# XDC: c:/Users/danny/OneDrive/Desktop/FPGA/i2s_demo/i2s_demo.gen/sources_1/ip/clk_wiz_0_1/clk_wiz_0.xdc
#dup# set_property KEEP_HIERARCHY SOFT [get_cells [split [join [get_cells -hier -filter {REF_NAME==clk_wiz_0 || ORIG_REF_NAME==clk_wiz_0} -quiet] {/inst } ]/inst ] -quiet] -quiet

# XDC: c:/Users/danny/OneDrive/Desktop/FPGA/i2s_demo/i2s_demo.gen/sources_1/ip/clk_wiz_0_1/clk_wiz_0_ooc.xdc
