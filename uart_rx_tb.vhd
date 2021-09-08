library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_rx_tb is
end uart_rx_tb;

architecture uart_rx_tb of uart_rx_tb is

	signal clock_in : std_logic := '0';
	signal reset_in : std_logic := '1';
	signal uart_data_rx : std_logic := '1';
	signal uart_rate_rx_sel : std_logic_vector(1 downto 0);
	signal data_p_out : std_logic_vector(7 downto 0);
	signal data_p_en_out : std_logic;


	signal counter : integer := 0;
	signal new_clk : std_logic := '0';

	type test_packet is array (3 downto 0) of std_logic_vector(9 downto 0);
	signal data : test_packet := (
		0 => "1101010100", -- x"AA"
		1 => "1111111110", -- x"FF"
		2 => "1000000000", -- x"00"
		3 => "1111100000"  -- x"F0"
	);
	signal pointer : integer := 0;
	signal position : integer := 0;



begin

uart: entity work.uart_rx 
	port map(
		clock_in => clock_in,
		reset_in => reset_in,
		uart_data_rx => uart_data_rx,
		uart_rate_rx_sel => uart_rate_rx_sel,
		data_p_out => data_p_out,
		data_p_en_out => data_p_en_out
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




reset_in <= '1', '0' after 10 ns;
clock_in <= not clock_in after 5 ns;

uart_rate_rx_sel <= "11";

tx: process(new_clk, reset_in)
	begin
		if reset_in = '1' then
			data <= (
				0 => "1101010100", -- x"AA"
				1 => "1111111110", -- x"FF"
				2 => "1000000000", -- x"00"
				3 => "1111100000"  -- x"F0"
			);
			pointer <= 0;
		elsif rising_edge(new_clk) then
			uart_data_rx <= data(position)(pointer);
			if pointer < 9 then
				pointer <= pointer + 1;
			else
				if position < 3 then
					position <= position + 1;
				else
					position <= 0;
				end if;
				pointer <= 0;
			end if;
		end if;
	end process tx;



end uart_rx_tb;
