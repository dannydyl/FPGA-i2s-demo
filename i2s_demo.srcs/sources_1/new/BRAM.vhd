----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/09/2024 06:49:14 PM
-- Design Name: 
-- Module Name: BRAM - Behavioral
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BRAM is
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
end BRAM;

architecture behavioral of BRAM is
    type ram_type is array (0 to 4095) of std_logic_vector(23 downto 0);
    signal ram : ram_type;
    signal write_ptr : integer range 0 to 4095 := 0;
    signal read_ptr  : integer range 0 to 4095 := 0;
    signal data_count : integer range 0 to 4096 := 0;
    signal sub_index : integer range 0 to 2 := 0; -- For slicing 24-bit into 3 x 8-bit
    signal full : std_logic := '0'; -- Indicates when the BRAM is full
    signal trigger : std_logic := '0';
    signal output_clock : std_logic := '0'; -- Output clock for controlling read rate
    signal clock_divider : integer := 0; -- Clock divider counter
    
    constant CLK_DIVIDER_MAX : integer := 4340; -- Divider for 11.52 kHz from 100 MHz
begin

    -- Clock division process
    process(clk)
    begin
        if rising_edge(clk) then
            if clock_divider < CLK_DIVIDER_MAX then
                clock_divider <= clock_divider + 1;
            else
                clock_divider <= 0;
                output_clock <= not output_clock; -- Toggle output clock
            end if;
        end if;
    end process;
    
    -- Memory access process
    process(lrck)
    begin
        if rising_edge(lrck) then
            -- Handle writing
            if i_data /= "000000000000000000000000" then
                ram(write_ptr) <= i_data;
                write_ptr <= (write_ptr + 1) mod 4096;
                data_count <= data_count + 1;
                trigger <= '1';
                if data_count = 4095 then -- Adjust for zero indexing
                    full <= '1'; -- Set full when buffer is completely filled
                end if;
            end if;
        end if;
    end process;

    -- Memory access process for reading
    process(output_clock)
    begin
        if reset_n = '0' then
            data_ready <= '0';
        elsif rising_edge(output_clock) then
            case sub_index is
                when 0 =>
                    o_data <= ram(read_ptr)(23 downto 16); -- High byte
                    sub_index <= 1;
                when 1 =>
                    o_data <= ram(read_ptr)(15 downto 8); -- Middle byte
                    sub_index <= 2;
                when 2 =>
                    o_data <= ram(read_ptr)(7 downto 0); -- Low byte
                    sub_index <= 0;
                    read_ptr <= (read_ptr + 1) mod 4096;
--                    data_count <= data_count - 1;
                when others =>
                    sub_index <= 0;
            end case;
            data_ready <= '1';
--            if data_count = 1 and sub_index = 0 then
--                -- Last data was read
--                data_ready <= '0';
--            else
--                data_ready <= '1';
--            end if;
        end if;
        
--        if output_clock = '1' then
--            data_ready <= '0';
--        end if;
    end process;
    -- Data ready signal indicates data is ready to be read
--    data_ready <= full; -- Data is ready when BRAM is full
end architecture;
