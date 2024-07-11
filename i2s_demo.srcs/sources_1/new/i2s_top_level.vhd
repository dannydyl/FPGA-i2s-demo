----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/10/2024 05:10:49 PM
-- Design Name: 
-- Module Name: i2s_receiver - Behavioral
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
LIBRARY ieee;
USE ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

ENTITY i2s_toplevel IS
    GENERIC(
        d_width     :  INTEGER := 24);                    --data width
    PORT(
        clk_in       :  IN  STD_LOGIC;                     --system clock (100 MHz on Basys board)
        reset_n     :  IN  STD_LOGIC;                     --active low asynchronous reset
        mclk        :  OUT std_logic;  --master clock
        sclk        :  OUT STD_LOGIC;  --serial clock (or bit clock)
        lrck        :  OUT STD_LOGIC;  --word select (or left-right clock)
        sd_rx       :  IN  STD_LOGIC;                     --serial data in
        l_data_rx    : out STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --left channel data received from I2S Transceiver component
        r_data_rx    : out STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)  --right channel data received from I2S Transceiver component
        );                    --serial data out
END i2s_toplevel;

ARCHITECTURE logic OF i2s_toplevel IS

    SIGNAL master_clk   :  STD_LOGIC;                             --internal master clock signal
    SIGNAL serial_clk   :  STD_LOGIC := '0';                      --internal serial clock signal
    SIGNAL left_right_clock  : STD_LOGIC := '0';                      --internal word select signal

    
     SIGNAL clk_in_bufg  :  STD_LOGIC;                             -- buffered clk_in signal
 
    --declare PLL to create 12.29508 which is nearest to 12.288MHz master clock from 100 MHz system clock
        component clk_wiz_0
        port
         (-- Clock in ports
          -- Clock out ports
          clk_out1          : out    std_logic;
          -- Status and control signals
          resetn             : in     std_logic;
          clk_in1           : in     std_logic
         );
        end component;
        
    --declare I2S Transceiver component
    COMPONENT i2s_receiver IS
        GENERIC(
            mclk_sclk_ratio :  INTEGER := 4;    --number of mclk periods per sclk period
            sclk_lrck_ratio   :  INTEGER := 64;   --number of sclk periods per word select period
            d_width         :  INTEGER := 24);  --data width
        PORT(
            reset_n     :  IN   STD_LOGIC;                              --asynchronous active low reset
            mclk        :  IN   STD_LOGIC;                              --master clock
            sclk        :  OUT  STD_LOGIC;                              --serial clock (or bit clock)
            lrck          :  OUT  STD_LOGIC;                              --word select (or left-right clock)
            sd_rx       :  IN   STD_LOGIC;                             --serial data receive
            l_data_rx   :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);   --left channel data received
            r_data_rx   :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)    --right channel data received
            ); 
    END COMPONENT;
    
    -- for ILA debuggin
--    COMPONENT ila_0
--    PORT (
--        clk : IN STD_LOGIC;
--        probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--        probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
--    );
--    END COMPONENT  ;
    
    signal mclk_vector : std_logic_vector(0 downto 0);
    signal sclk_vector : std_logic_vector(0 downto 0);
    signal lrck_vector : std_logic_vector(0 downto 0);
    signal sd_rx_vector : std_logic_vector(0 downto 0);
BEGIN
--    -- Buffer the clk_in signal
--    clk_in_ibufg: IBUF
--        PORT MAP (
--            I => clk_in,
--            O => clk_in_bufg
--        );
    --instantiate PLL to create master clock
    i2s_clock: clk_wiz_0 
    PORT MAP(
             clk_in1 => clk_in, 
            resetn => reset_n,
            clk_out1 => master_clk);
  
    --instantiate I2S Transceiver component
    i2s_transceiver_0: i2s_receiver
    GENERIC MAP(mclk_sclk_ratio => 4, sclk_lrck_ratio => 64, d_width => 24)
        PORT MAP(
                    reset_n => reset_n, 
                    mclk => master_clk, 
                    sclk => serial_clk, 
                    lrck => left_right_clock, 
                    sd_rx => sd_rx,
                    l_data_rx => l_data_rx,
                    r_data_rx => r_data_rx); --commented this because i cant have 48 IO pins physcially but since this is for testing, signals are commented
                    
--          ILA_debugging : ila_0
--        PORT MAP (
--            clk => clk_in_bufg,
--            probe0 => mclk_vector,
--            probe1 => sclk_vector, 
--            probe2 => lrck_vector,
--            probe3 => sd_rx_vector
--        );
    
    mclk_vector(0) <= master_clk;
    sclk_vector(0) <= serial_clk;
    lrck_vector(0) <= left_right_clock;
    sd_rx_vector(0) <= sd_rx;
        
        
    mclk <= master_clk;  --output master clock to ADC
    sclk <= serial_clk;  --output serial clock (from I2S Transceiver) to ADC
    lrck <= left_right_clock;   --output word select (from I2S Transceiver) to ADC


END logic;



