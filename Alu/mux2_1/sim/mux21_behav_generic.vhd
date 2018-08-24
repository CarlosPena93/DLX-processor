library IEEE;
use IEEE.std_logic_1164.all;
use WORK.constants.all;

entity MUX21_BEHAV_GENERIC is
	GENERIC( N_BIT:INTEGER;DELAY_MUX: Time:= tp_mux);
	PORT(
		A:IN std_logic_vector(N_BIT-1 downto 0);
		B:IN std_logic_vector(N_BIT-1 downto 0);
		S:IN std_logic;
		Y:OUT std_logic_vector(N_BIT-1 downto 0));
   end MUX21_BEHAV_GENERIC;


architecture BEHAVIORAL of MUX21_BEHAV_GENERIC is

begin
	Y <= A when S='1' else B;

end BEHAVIORAL;



