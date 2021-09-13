set_db library /soft64/design-kits/stm/65nm-cmos065_536/CORE65GPSVT_5.1/libs/CORE65GPSVT_nom_1.00V_25C.lib
read_hdl -vhdl fifo_async.vhd
read_hdl -vhdl uart_rx.vhd
elaborate uart_rx
read_sdc ./constraints.sdc
synthesize -to_generic -effort high
synthesize -to_mapped -effort high


report_timing > timing.txt
report_area > area.txt
report_power > power.txt
