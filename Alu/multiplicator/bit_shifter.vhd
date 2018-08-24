library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic

entity bit_shifter is-- left shifter by 0
	GENERIC(N_BIT:integer;Shift:integer);--N_bit is for the lenght of the arrray and shift is for the number of bits we shifts
	Port (	A:	In	std_logic_vector(N_bit*2-1 downto 0);
		Y:	Out	std_logic_vector(N_bit*2-1 downto 0));
end bit_shifter;

architecture BEHAVIORAL of bit_shifter is
signal interm: std_logic_vector(N_bit*2+(Shift-1) downto 0);--use a longer array to concatanate
signal Num_shifts: std_logic_vector(shift-1 downto 0);
begin
	Num_shifts<= (Others =>'0'); --array containing the number of shifts
	interm <= A&Num_shifts; -- concatanate the previus array 
	Y<=interm(N_bit*2-1 downto 0); -- select the low part of the intern for the output
end BEHAVIORAL;
