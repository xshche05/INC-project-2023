-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Name Surname (xshche05)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
signal CNT_CLK : std_logic_vector(4 downto 0);
signal CNT_DATA : std_logic_vector(3 downto 0);
signal CNT_CLK_EN : std_logic;
signal RX_EN : std_logic;
signal VLD : std_logic;
begin
    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        CNT_CLK => CNT_CLK,
        CNT_CLK_EN => CNT_CLK_EN,
        CNT_DATA => CNT_DATA,
        RX_EN => RX_EN,
        VLD => VLD
    );
    DOUT_VLD <= VLD;
    process (CLK) begin
                    if rising_edge(CLK) then
                      if RST = '1' then
                        DOUT <= "00000000";
                        CNT_CLK <= "00001";
                        CNT_DATA <= "0000";
                      else
                        if CNT_CLK_EN = '1' then
                          CNT_CLK <= CNT_CLK + 1;
                        else
                          CNT_CLK <= "00001";
                        end if;
                        if RX_EN = '1' and CNT_CLK(4) = '1' then
                          DOUT(conv_integer(CNT_DATA)) <= DIN;
                          CNT_DATA <= CNT_DATA + 1;
                          CNT_CLK <= "00001";
                        end if;
                        if RX_EN = '0' then
                          CNT_DATA <= "0000";
                        end if;
                      end if;
                    end if;
                    
    end process;
end behavioral;
