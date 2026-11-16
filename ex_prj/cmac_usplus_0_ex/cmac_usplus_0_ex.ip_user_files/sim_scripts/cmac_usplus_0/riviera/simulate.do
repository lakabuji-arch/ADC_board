transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+cmac_usplus_0  -L xil_defaultlib -L xilinx_vip -L xpm -L gtwizard_ultrascale_v1_7_22 -L cmac_usplus_v3_1_24 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.cmac_usplus_0 xil_defaultlib.glbl

do {cmac_usplus_0.udo}

run 1000ns

endsim

quit -force
