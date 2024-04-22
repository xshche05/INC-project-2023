-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Name Surname (xshche05)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       DIN : in std_logic;
       CNT_CLK : in std_logic_vector(4 downto 0);
       CNT_CLK_EN: out std_logic;
       CNT_DATA : in std_logic_vector(3 downto 0);
       RX_EN : out std_logic;
       VLD : out std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is
type FSM_STATE is (IDLE, START, DATA, WAIT_STOP, VALID);
signal state : FSM_STATE := IDLE;
begin
  RX_EN <= '1' when state = DATA else '0';
  VLD <= '1' when state = VALID else '0';
  CNT_CLK_EN <= '1' when state = START or state = DATA or state = WAIT_STOP else '0';
  process (CLK) begin
                  if rising_edge(CLK) then
                    if RST = '1' then
                      state <= IDLE;
                    else
                      case state is
                        when IDLE => if DIN = '0' then
                                       state <= START;
                                     end if;
                        when START => if CNT_CLK = "10111" then
                                        state <= DATA;
                                      end if;
                        when DATA => if CNT_DATA = "1000" then
                                       state <= WAIT_STOP;
                                     end if;
                        when WAIT_STOP => if CNT_CLK > "10000" then
                                            state <= VALID;
                                          end if;
                        when VALID => state <= IDLE;
                      end case;
                    end if;
                  end if;
  end process;
end architecture;
