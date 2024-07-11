----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/09/2024 11:35:36 PM
-- Design Name: 
-- Module Name: i2s_demo_top_level_tb - Behavioral
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
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY i2s_demo_top_level_tb IS
END i2s_demo_top_level_tb;

ARCHITECTURE behavior OF i2s_demo_top_level_tb IS 
    -- Signal declarations
    SIGNAL clk_in         : std_logic := '0';
    SIGNAL reset_n        : std_logic := '1';
    SIGNAL mclk           : std_logic;
    SIGNAL sclk           : std_logic;
    SIGNAL lrck           : std_logic;
    SIGNAL sd_rx          : std_logic := '0';
    SIGNAL uart_tx_serial : std_logic;

    -- Component declaration of the UUT
    COMPONENT i2s_demo_top_level
        PORT(
            clk_in         : IN  std_logic;
            reset_n        : IN  std_logic;
            mclk           : OUT std_logic;
            sclk           : OUT std_logic;
            lrck           : OUT std_logic;
            sd_rx          : IN  std_logic;
            uart_tx_serial : OUT std_logic
        );
    END COMPONENT;

    -- Audio sample data - this should be modified to reflect real audio sample data
    TYPE audio_array IS ARRAY(natural RANGE <>) OF std_logic_vector(23 DOWNTO 0);
    CONSTANT audio_samples : audio_array := (
        x"000000", x"FFFFF0", x"000010", x"FFFFF0",
        x"000020", x"FFFFF0", x"000030", x"FFFFF0"
        -- Add more samples to simulate more complex audio patterns
    );
    SIGNAL sample_index : integer RANGE 0 TO audio_samples'LENGTH - 1 := 0;
 -- LFSR signal
    SIGNAL lfsr_reg: std_logic_vector(7 downto 0) := "00000001";  -- Non-zero initial value
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: i2s_demo_top_level PORT MAP (
        clk_in         => clk_in,
        reset_n        => reset_n,
        mclk           => mclk,
        sclk           => sclk,
        lrck           => lrck,
        sd_rx          => sd_rx,
        uart_tx_serial => uart_tx_serial
    );

    stim_proc: PROCESS
    BEGIN
        reset_n <= '0';
        WAIT FOR 20 ns;
        reset_n <= '1';
        WAIT FOR 500 ns;  -- Simulate for a specific duration
        WAIT;
    END PROCESS;
    -- Clock process definitions
    clk_process :PROCESS
    BEGIN
        clk_in <= '0';
        WAIT FOR 5 ns;
        clk_in <= '1';
        WAIT FOR 5 ns;
    END PROCESS;

    -- LFSR for pseudo-random data generation
    lfsr_process: PROCESS(clk_in)
    BEGIN
        IF rising_edge(clk_in) THEN
            IF reset_n = '0' THEN
                lfsr_reg <= "00000001";  -- Reset to non-zero
            ELSE
                lfsr_reg <= lfsr_reg(6 downto 0) & (lfsr_reg(7) XOR lfsr_reg(5));  -- Example feedback polynomial: x^8 + x^6 + 1
            END IF;
        END IF;
    END PROCESS;

    -- Assign the least significant bit of LFSR to sd_rx
    sd_rx <= lfsr_reg(0);

END behavior;
