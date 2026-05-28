open_project cmac_usplus_0_ex.xpr
set_param general.maxThreads 8
# Suppress DDR4 model "Writing unknowns" warnings
set_msg_config -suppress -string "Writing unknowns"
launch_simulation -simset sim_1 -mode behavioral
run all
close_sim
close_project
