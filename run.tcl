vlib work
vcom ./uart_rx.vhd
vcom ./uart_rx_tb.vhd
vsim -novopt -wlf /sim/t1 -wlfdeleteonquit work.uart_rx_tb
#add wave sim:/uart_rx_tb/*
do wave.do
run 300 ns
