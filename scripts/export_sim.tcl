open_project cmac_usplus_0_ex.xpr
set_param general.maxThreads 8
# Export sim scripts only, then we'll run manually
export_simulation -simset sim_1 -mode behavioral -directory xsim_fresh
