----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/09/2024 12:08:12 AM
-- Design Name: 
-- Module Name: i2s_demo_top_level - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.Vcomponents.all;

entity i2s_demo_top_level is
    port(
        clk_in         : in  std_logic;   -- system clock (100 MHz)
        reset_n        : in  std_logic;   -- active low asynchronous reset
        reset_n2       : in std_logic;
        mclk           : out std_logic;   -- master clock
        sclk           : out std_logic;   -- serial clock (or bit clock)
        lrck           : out std_logic;   -- word select (or left-right clock)
        sd_rx          : in  std_logic;   -- serial data in
        uart_tx_serial : out std_logic    -- UART TX serial data
    );
end i2s_demo_top_level;

architecture Behavioral of i2s_demo_top_level is

    signal master_clk     : std_logic;
    signal serial_clk     : std_logic;
    signal left_right_clk : std_logic;
    signal l_data_rx      : std_logic_vector(23 downto 0);
    signal r_data_rx      : std_logic_vector(23 downto 0);
    signal uart_tx_start  : std_logic := '0';
    signal uart_tx_data   : std_logic_vector(7 downto 0);
    signal uart_tx_busy   : std_logic;
    signal bram_data_ready: std_logic := '0';


    component i2s_toplevel
        generic (
            d_width : integer := 24
        );
        port (
            clk_in     : in  std_logic;
            reset_n    : in  std_logic;
            mclk       : out std_logic;
            sclk       : out std_logic;
            lrck       : out std_logic;
            sd_rx      : in  std_logic;
            l_data_rx  : out std_logic_vector(d_width-1 downto 0);
            r_data_rx  : out std_logic_vector(d_width-1 downto 0)
        );
    end component;

    component UART_TX
        generic (
            g_CLKS_PER_BIT : integer := 10417  -- Needs to be set correctly
        );
        port (
            i_Clk       : in  std_logic;
            i_TX_DV     : in  std_logic;
            i_TX_Byte   : in  std_logic_vector(7 downto 0);
            o_TX_Active : out std_logic;
            o_TX_Serial : out std_logic;
            o_TX_Done   : out std_logic
        );
    end component;

    component BRAM
    port (
        clk           : in std_logic;
        lrck          : in std_logic;
        reset_n       : in std_logic;
        i_data        : in std_logic_vector(23 downto 0);
        i_write       : in std_logic;
        o_data        : out std_logic_vector(7 downto 0);
        o_read        : in std_logic;
        data_ready    : out std_logic
    );
    end component;
    
    signal write_enable : std_logic := '0';
    signal read_enable  : std_logic := '0';
    signal bram_data_out: std_logic_vector(7 downto 0);
    signal bram_write_en : std_logic := '1';  -- Always enable write
    signal bram_read_en  : std_logic;
    
    -- Buffer the clk_in signal
    signal clk_in_buf : std_logic;
    signal clk_buf    : std_logic;
    signal reset_n_buf  : std_logic;
    
    signal tx_state      : integer range 0 to 2 := 0; -- State to manage which byte to send
begin

    -- Buffer the clk_in signal using a global buffer
--    clk_in_bufg : IBUF
--        port map (
--            I => clk_in,
--            O => clk_in_buf
--        );

    clk_bufg : BUFG
        port map (
            I => clk_in,
            O => clk_buf
        );
        
    -- Instantiate the input buffer (IBUF) for reset signal
    reset_n_ibuf: IBUF
        port map (
            I => reset_n,
            O => reset_n_buf
        );
  -- Instantiate the I2S top-level entity
    i2s_inst: i2s_toplevel
    generic map (
        d_width => 24
    )
    port map (
        clk_in     => clk_buf,
        reset_n    => reset_n_buf,
        mclk       => master_clk,
        sclk       => serial_clk,
        lrck       => left_right_clk,
        sd_rx      => sd_rx,
        l_data_rx  => l_data_rx,
        r_data_rx  => r_data_rx
    );

    -- Instantiate the BRAM component
    bram_inst: BRAM
    port map (
        clk       => clk_buf,
        lrck      => left_right_clk,
        reset_n   => reset_n2,
        i_data  => l_data_rx,
        i_write   => write_enable,
        o_data   => bram_data_out,
        o_read  => bram_read_en,
        data_ready => bram_data_ready
    );
    
    -- Instantiate the UART transmitter
    uart_tx_inst: UART_TX
    generic map (
        g_CLKS_PER_BIT => 868  -- Adjust for your specific baud rate
    )
    port map (
        i_Clk       => clk_buf,
        i_TX_DV     => uart_tx_start,
        i_TX_Byte   => bram_data_out,
        o_TX_Active => uart_tx_busy,
        o_TX_Serial => uart_tx_serial,
        o_TX_Done   => open
    );
    
    bram_read_en <= bram_data_ready;
    -- Generate the serial clocks
    mclk <= master_clk;  -- Output master clock to ADC
    sclk <= serial_clk;  -- Output serial clock (from I2S receiver) to ADC
    lrck <= left_right_clk;  -- Output word select (from I2S receiver) to ADC

    -- Control UART transmission start based on data availability and UART busy status
    process(clk_buf)
    begin
       if rising_edge(clk_buf) then
            if bram_data_ready = '1' and uart_tx_busy = '0' then
                uart_tx_start <= '1';
            else
                uart_tx_start <= '0';
            end if;
        end if;
    end process;

 -- Serialization and Transmission Control Logic
--    process(clk_buf, reset_n)
--    begin
--        if reset_n = '0' then
--            uart_tx_start <= '0';
--            tx_state <= 0;
--        elsif rising_edge(clk_buf) then
--            write_enable <= '1' when lrck = '0' else '0';
--            if bram_data_ready = '1' and uart_tx_busy = '0' then
--                case tx_state is
--                    when 0 =>
--                        uart_tx_data <= bram_data_out(23 downto 16);  -- MSB
--                        uart_tx_start <= '1';
--                        tx_state <= 1;
--                    when 1 =>
--                        uart_tx_data <= bram_data_out(15 downto 8);  -- Middle byte
--                        uart_tx_start <= '1';
--                        tx_state <= 2;
--                    when 2 =>
--                        uart_tx_data <= bram_data_out(7 downto 0);  -- LSB
--                        uart_tx_start <= '1';
--                        tx_state <= 0;  -- Reset to MSB for the next sample
--                    when others =>
--                        uart_tx_start <= '0';
--                        tx_state <= 0;
--                end case;
--            else
--                uart_tx_start <= '0';
--            end if;
--        end if;
--    end process;

end Behavioral;
