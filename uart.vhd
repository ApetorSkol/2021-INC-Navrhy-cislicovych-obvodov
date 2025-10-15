-- uart.vhd: UART controller - receiving part
-- Author(s): xslivk03
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0) ;
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
signal count_clk : std_logic_vector(4 downto 0) := "00000";
signal count_clk2: std_logic_vector(3 downto 0) := "0000";
signal count_bit : std_logic_vector(3 downto 0) := "0000";
signal inword    : std_logic;
begin

FSM: entity work.UART_FSM(behavioral)
port map (
    CLK			=> CLK,
    RST			=> RST,
    DIN			=> DIN,
	CNTCLK		=> count_clk,
	CNTCLK2		=> count_clk2,
	CNTBIT		=> count_bit,
	INWORD		=> inword,
	DOUT_VLD	=> DOUT_VLD
);

process (CLK) begin
	if RST = '1' then
		count_clk <= (others => '0');
		count_bit <= (others => '0');
		count_clk2 <= (others => '0');
	else
		if rising_edge(CLK) then
			if count_clk < "10100" then
				count_clk <= count_clk + 1;
			else
				if inword = '1' then
					if count_clk2 = "1000" then
						count_clk2 <= (others => '0');
						case count_bit is
							when "0000" => DOUT(0) <= DIN;
							when "0001" => DOUT(1) <= DIN;
							when "0010" => DOUT(2) <= DIN;
							when "0011" => DOUT(3) <= DIN;
							when "0100" => DOUT(4) <= DIN;
							when "0101" => DOUT(5) <= DIN;
							when "0110" => DOUT(6) <= DIN;
							when "0111" => DOUT(7) <= DIN;
								count_clk <= "00000";
							when others => null;
						end case;
						count_bit <= count_bit + 1;
					end if;
					count_clk2 <= count_clk2 +1;
				else
					count_bit <= (others => '0');
				end if;
			end if;
		end if;
	end if;
end process;

end behavioral;
