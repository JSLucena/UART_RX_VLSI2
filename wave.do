onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_rx_tb/clock_in
add wave -noupdate /uart_rx_tb/reset_in
add wave -noupdate /uart_rx_tb/uart_data_rx
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_rate_rx_sel
add wave -noupdate -radix hexadecimal /uart_rx_tb/data_p_out
add wave -noupdate /uart_rx_tb/data_p_en_out
add wave -noupdate /uart_rx_tb/uart/new_clk
add wave -noupdate /uart_rx_tb/uart/counter
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart/data_buffer
add wave -noupdate /uart_rx_tb/uart/byte_ready
add wave -noupdate -radix decimal /uart_rx_tb/uart/byte_counter
add wave -noupdate /uart_rx_tb/uart/state
add wave -noupdate /uart_rx_tb/uart/next_state
add wave -noupdate /uart_rx_tb/uart/discard_bit
add wave -noupdate /uart_rx_tb/uart/fifo/wr_en
add wave -noupdate /uart_rx_tb/uart/fifo/rd_en
add wave -noupdate /uart_rx_tb/uart/fifo/sts_empty
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart/fifo/wr_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart/fifo/rd_data
add wave -noupdate -radix binary /uart_rx_tb/uart/fifo/mem
add wave -noupdate /uart_rx_tb/uart/fifo/sts_error
add wave -noupdate /uart_rx_tb/uart/teste
add wave -noupdate /uart_rx_tb/uart/fifo/rd_clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {175053 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 208
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1050315 ns}
