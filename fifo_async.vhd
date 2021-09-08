library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fifo_async is
port
(
	rd_clk, wr_clk, rst, wr_en, rd_en: in std_logic;
	sts_error, sts_full, sts_high, sts_low, sts_empty : out std_logic;
	wr_data : in std_logic_vector(7 downto 0);
	rd_data : out std_logic_vector(7 downto 0)
);
end fifo_async;

architecture fifo_async of fifo_async is
type queue is array(0 to 63) of std_logic_vector(7 downto 0);--MUDAR CASO NECESSARIO AUMENTAR A MEMORIA
--signals
signal mem : queue := (others=>x"00");
signal wr_pointer : integer range 0 to 63 := 0;--MUDAR CASO NECESSARIO AUMENTAR A MEMORIA
signal rd_pointer : integer range 0 to 63 := 0; --MUDAR CASO NECESSARIO AUMENTAR A MEMORIA
signal mem_size : integer := 64; -- MUDAR CASO NECESSARIO AUMENTAR MEMORIA

signal sts_empty_in, sts_full_in , sts_low_in, sts_high_in: std_logic; -- sinais internos para calcular o sts_error

--signal lastOp : std_Logic_vector(1 downto 0):= "00"; -- indica se a ultima operacao foi escrita ou leitura
signal lastOp : std_Logic := '0';
signal read_sniffer, write_sniffer : std_logic := '0';
begin


	write_process : process(wr_clk,rst) ---processo ligado ao clock de escrita
	begin
		if rst = '1' then
			wr_pointer <= 0;
			mem <= (others => x"00");
		
		elsif rising_edge(wr_clk) then
			if wr_en = '1' then
				write_sniffer <= '1';
				mem(wr_pointer) <= wr_data;
				
				
				if wr_pointer >= 63 then ---MUDAR CASO NECESSARIO AUMENTAR A MEMORIA
					wr_pointer <= 0;
				else
					wr_pointer <= wr_pointer + 1;
				end if;
			else
				write_sniffer <= '0';
			end if;
		end if;
	end process write_process;
	
	read_process : process(rd_clk,rst) --- processo ligado ao clock de leitura
	begin
		if rst = '1' then
			rd_pointer <= 0;
			rd_data<= x"00";
		elsif rising_edge(rd_clk) then
			if rd_en = '1' then
				read_sniffer <= '1';
				rd_data <= mem(rd_pointer);
				
				if rd_pointer >= 63 then ---MUDAR CASO NECESSARIO AUMENTAR A MEMORIA
					rd_pointer <= 0;
				else
					rd_pointer <= rd_pointer + 1;
				end if;
			else
				read_sniffer <= '0';
			end if;
		end if;
	end process read_process;
	
	
	
--	lastOp_process : process(rst,read_sniffer,write_sniffer)
--	begin
--		if rst = '1' then
--			lastOp <= "00";
--		else
--			if lastOp /= "00" then
--				lastOp <= "00";
--			end if;
--							
--			if write_sniffer ='1' then
--				lastOp <= "10";
--			end if;
--			
--			if read_sniffer = '1' then
--				lastOp <= lastOp + '1';
--			end if;
--		end if;
--	end process lastOp_process;
	
	
	
	control_process : process(wr_pointer,rd_pointer,rst)
	begin
		if rst = '1' then
			sts_error <= '0';
			sts_full <= '0';
			sts_high <= '0';
			sts_low <= '1';
			sts_empty <= '1';
			sts_empty_in <= '1';
			sts_full_in <= '0';
			sts_low_in <= '1';
			sts_high_in <= '0';
			
			lastOp <= '0';
		else					
			if sts_low_in ='1' then
				lastOp <= '0';
			else
				if sts_high_in = '1' then
					lastOp <= '1';
				end if;
			end if;
		
		
		
			------BLOCO VAZIO/CHEIO------
			if wr_pointer = rd_pointer then
				if sts_high_in = '1' and sts_low_in = '0' then --ultima operacao foi escrita
					sts_full_in <= '1';
					sts_full <= '1';
				elsif sts_high_in = '0' and sts_low_in = '1' then
					sts_empty_in <= '1'; -- ultima operacao foi leitura
					sts_empty <= '1';
				end if;
			else
				sts_full_in <= '0';
				sts_empty_in <= '0';
				
			sts_empty <= '0';
			sts_full <= '0';
			end if;
			-----------------------------
			
			-----BLOCO HIGH/LOW----------
			
			if wr_pointer > rd_pointer then
			
				if (wr_pointer - rd_pointer) >= mem_size - 4 then
					sts_high <= '1';
					sts_high_in <= '1';
				else
					sts_high <= '0';
					sts_high_in <= '0';
				end if;
			elsif wr_pointer < rd_pointer then
				if (wr_pointer + mem_size - rd_pointer) >= mem_size - 4 then
					sts_high <= '1';
					sts_high_in <= '1';
				else
					sts_high <= '0';
					sts_high_in <= '0';
				end if;
			else
				if (wr_pointer + mem_size - rd_pointer) >= mem_size - 4 then
					if lastOp = '1' then
						sts_high <= '1';
						sts_high_in <= '1';
					end if;
				else
					sts_high <= '0';
					sts_high_in <= '0';
				end if;
				
			end if;
			
			
			
			if wr_pointer > rd_pointer then
				if (wr_pointer - rd_pointer) <= 4 then
					sts_low <= '1';
					sts_low_in <= '1';
				else
					sts_low <= '0';
					sts_low_in <= '0';
				end if;	
			elsif wr_pointer < rd_pointer then
				if (wr_pointer + mem_size - rd_pointer) <= 4 then
					sts_low <= '1';
					sts_low_in <= '1';
				else
					sts_low <= '0';
					sts_low_in <= '0';
				end if;
			else
				if (wr_pointer - rd_pointer) <= 4 then
				
					if lastOp = '0' then
						sts_low <= '1';
						sts_low_in <= '1';
					end if;
				else
					sts_low <= '0';
					sts_low_in <= '0';
				end if;
			end if;
			 
			-----------------------------
			
			
			-----BLOCO DO ERRO---------
			if sts_empty_in = '1' then
				if wr_pointer < rd_pointer then
					sts_error <= '1';
				end if;
				
			elsif sts_full_in = '1' then
				if wr_pointer > rd_pointer then
					sts_error <= '1';
				end if;
			end if;
			--------------------------
			
				
		end if;
		
	end process control_process;			
		

 end fifo_async;
