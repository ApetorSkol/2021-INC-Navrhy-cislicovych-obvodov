-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): xslivk03

--
library ieee;
use ieee.std_logic_1164.all;
-------------------------------------------------
entity UART_FSM is
port(
	CLK : in std_logic;
	RST : in std_logic;
	DIN : in std_logic;
	CNTCLK : in std_logic_vector(4 downto 0) := "00000";
	CNTCLK2: in std_logic_vector(3 downto 0) := "0000";
	CNTBIT : in std_logic_vector(3 downto 0) := "0000";
	INWORD : out std_logic;
	DOUT_VLD : out std_logic
	);
end entity UART_FSM;
-------------------------------------------------
architecture behavioral of UART_FSM is
type stav is (START, WAIT_FIRST, DATA, WAIT_LAST);
signal state : stav := START;
begin
	process (CLK) begin
		if RST = '1' then
			state <= START;
			INWORD <= '0';
			DOUT_VLD <= '0';
		else
			if rising_edge(CLK) then
				case state is
					when START => if DIN = '0' then 
						DOUT_VLD <= '0';
						INWORD <= '0';
						state <= WAIT_FIRST; 
					end if;
					when WAIT_FIRST => if CNTCLK = "10100" then
						state <= DATA;
						INWORD <= '1';
					end if;
					when DATA => if CNTBIT = "1000" then
						state <= WAIT_LAST;
						INWORD <= '0';
						DOUT_VLD <= '1';
					end if;
					when WAIT_LAST =>
						DOUT_VLD <= '0';
						if DIN = '1' then
							state <= START;
						end if;
					when others => null;
				end case;
			end if;
		end if;
	end process;
end behavioral;
