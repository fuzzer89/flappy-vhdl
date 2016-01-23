library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hcsr04 is
	port (
		clk        : in  std_logic;
		echo       : in  std_logic;
		trig       : out std_logic;
		done       : out std_logic;
		pulse_width : out std_logic_vector(22 downto 0)
	);
end;

architecture rtl of hcsr04 is
	constant max_period  : unsigned(22 downto 0) := "01001100010010110100000"; -- 50 ms
	constant no_obstacle : unsigned(22 downto 0) := "00111001111110111100000"; -- 38 ms
begin
	process(clk)
		variable period_counter : unsigned(22 downto 0) := (others => '0');
		variable width_counter  : unsigned(22 downto 0) := (others => '0');
	begin
		if rising_edge(clk) and clk = '1' then
			-- Increment counter
			period_counter := period_counter + 1;

			-- Pulse the trigger for 24 µs
			if period_counter < 120 then
				trig <= '1';
			else
				trig <= '0';
			end if;

			if echo = '1' and period_counter < no_obstacle then
				-- Count within interval
				width_counter := width_counter + 1;
			end if;

			if period_counter = (max_period - 1) then -- 50 ms
				-- Set output based on pulse width
				pulse_width <= std_logic_vector(width_counter(22 downto 0));
				-- Signal that a measurement is completed
				done <= '1';
			elsif period_counter = max_period then
				-- Reset counters
				period_counter := (others => '0');
				width_counter  := (others => '0');
				done <= '0';
			else
				done <= '0';
			end if;
		end if;
	end process;
end;