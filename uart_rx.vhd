library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;

entity uart_rx is
port(
	clock_in, reset_in : in std_logic;
	uart_data_rx : 		 in std_logic;
	uart_rate_rx_sel : 	 in std_logic_vector(1 downto 0);
	data_p_out : 		 out std_logic_vector(7 downto 0);
	data_p_en_out : 	 out std_logic
);
end uart_rx;

architecture uart_rx of uart_rx is


signal new_clk : std_logic := '0';
signal counter : integer := 0;

signal data_p_en_out_in :std_logic := '0';

type FSM_States is (idle, start_recv,receive, output);
signal state, next_state : FSM_states := idle;

signal byte_ready : std_logic := '0';
signal byte_counter : integer := 0;

signal data_buffer : std_Logic_vector(7 downto 0);
signal discard_bit : std_logic := '0';

signal delay_clock : std_logic := '0';

signal teste : std_logic_vector(7 downto 0);

----- Sinais da fifo---------------
signal fifo_clk : std_logic := '0';
signal wr_en, rd_en : std_logic := '0';
signal sts_error, sts_full, sts_high, sts_low, sts_empty :std_logic;
signal wr_data : std_logic_vector(7 downto 0);
signal rd_data : std_logic_vector(7 downto 0);
signal fifo_counter : integer := 0;
-----------------------------------

begin

fifo: entity work.fifo_async port map(
		wr_clk => fifo_clk,
		rd_clk => fifo_clk,
		rst => reset_in,
		wr_en => wr_en,
		rd_en => rd_en,
		sts_error=>sts_error, 
		sts_full=>sts_full, 
		sts_high=>sts_high, 
		sts_low=>sts_low, 
		sts_empty=>sts_empty,
		wr_data => wr_data,
		rd_data => rd_data
	);




	divclk : process(clock_in,reset_in)
	begin
		if reset_in = '1' then
			counter <= 0;
		elsif rising_edge(clock_in) then
			counter <= counter + 1;
			
			if uart_rate_rx_sel = "00" and counter >= 5200 then
				new_clk <= not new_clk;
				counter <= 0;
			elsif uart_rate_rx_sel = "01" and counter >= 2603 then
				new_clk <= not new_clk;
				counter <= 0;
			elsif uart_rate_rx_sel = "10" and counter >= 1735 then
				new_clk <= not new_clk;
				counter <= 0;
			elsif uart_rate_rx_sel = "11" and counter >= 867 then
				new_clk <= not new_clk;
				counter <= 0;
			end if;
		end if;
	end process divclk;
	
	fifoclk : process(clock_in,reset_in)
	begin
		if reset_in = '1' then
			fifo_counter <= 0;
		elsif rising_edge(clock_in) then
			fifo_counter <= fifo_counter + 1;
			
			if fifo_counter = 500 then
				fifo_clk <= not fifo_clk;
				fifo_counter <= 0;
			end if;
		end if;
	end process fifoclk;


	

	next_state_logic : process(clock_in, reset_in)
	begin
			if reset_in = '1' then
				state <= idle;
			elsif rising_edge(clock_in) then
				state <= next_state;
			end if;
	end process next_state_logic;

	FSM : process(clock_in, reset_in)
	begin
		if reset_in = '1' then
			next_state <= idle;
			
		elsif rising_edge(clock_in) then
			if state = idle then
				if uart_data_rx = '0' then
					next_state <= start_recv;
				end if;
			elsif state = start_recv then
				next_state <= receive;
				
			elsif state = receive then
				--if byte_ready = '1' then
					--state <= output;
				if byte_counter = 8 and uart_data_rx = '1' then
					next_state <= idle;
				end if;
			elsif state = output then
				next_state <= idle;

			end if;
		end if;
	end process FSM;

	
--	fifo_read : process(fifo_clk, reset_in)
--	begin
--		if reset_in = '1' then
--			wr_data <= (others => '0');
--			rd_en <= '0';
--			wr_en <= '0';
--		--	data_buffer <= (others => '0');
--		--	byte_counter <= 0;
--		elsif rising_edge(fifo_clk) then
--
--			if byte_ready = '1' then
--				wr_data <= data_buffer;
--				wr_en <= '1';
--			else
--				wr_en <= '0';
--			end if;
--			
--			if sts_empty = '0' then
--				rd_en <= '1';
--			else
--				rd_en <= '0';
--			end if;
--			
--		end if;
--	end process fifo_read;


	read_process : process(new_clk, reset_in)
	begin
		if reset_in = '1' then
			data_buffer <= (others => '0');
			byte_counter <= 0;
			discard_bit <= '1';
			--delay_clock <= '0';
		elsif rising_edge(new_clk) then
		
			if state = receive then
				
				if byte_counter = 0 and discard_bit = '1' then
					discard_bit <= '0';
				else
					if byte_counter < 8 then
						data_buffer(byte_counter) <= uart_data_rx;
						byte_counter <= byte_counter + 1;
						
						
						
					else
						byte_counter <= 0;
						
					end if;
				end if;
			
			end if;
		end if;
	end process read_process;
	
	
	en_out : process(fifo_clk, reset_in)
	begin
		if reset_in = '1' then
			data_p_en_out <= '0';
			data_p_en_out_in <= '0';
		elsif rising_edge(fifo_clk) then
			if byte_counter < 8 then
				delay_clock <= '0';
				--data_p_en_out <= '0';
				--data_p_en_out_in <= '0';
			else
				delay_clock <= '1';
				--data_p_en_out <= '1';
				--data_p_en_out_in <= '1';
			end if;
			
			if delay_clock = '1' then
				data_p_en_out <= '1';
				data_p_en_out_in <= '1';
			else
				data_p_en_out <= '0';
				data_p_en_out_in <= '0';
			end if;
		end if;
	end process en_out;
	
	control_process : process(clock_in, reset_in)
	begin
		if reset_in = '1' then
			byte_ready <= '0';
		--	data_p_en_out <= '0';
		--	data_p_en_out_in <= '0';
			wr_data <= (others => '0');
			rd_en <= '0';
			wr_en <= '0';
		elsif rising_edge(clock_in) then
			
			
			
			
			if byte_counter < 8 then
			--	data_p_en_out <= '0';
			--	data_p_en_out_in <= '0';
				byte_ready <= '0';
			else
			--	data_p_en_out <= '1';
			--	data_p_en_out_in <= '1';
				byte_ready <= '1';
			end if;
			
			if byte_ready = '1' then
				wr_data <= data_buffer;
				wr_en <= '1';
			else
				wr_en <= '0';
			end if;
			
			
						
			if sts_empty = '0' then
				rd_en <= '1';
				
			else
				rd_en <= '0';
			end if;
			
			
		end if;
	end process control_process;
			
			
			
	
			
	output_process : process(clock_in, reset_in)
	begin
		if reset_in = '1' then
			
			data_p_out <= (others => '0');
		elsif rising_edge(clock_in) then
			if data_p_en_out_in = '1' then
				data_p_out <= rd_data;
			end if;
		end if;
	end process output_process;
	
end uart_rx;
