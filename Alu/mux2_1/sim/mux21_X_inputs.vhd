library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined

entity MUX21_STRUCT_X is
	generic(NumBit:integer);
	Port (	A:	In	std_logic_vector(Numbit-1 downto 0);
		B:	In	std_logic_vector(Numbit-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(Numbit-1 downto 0););
end MUX21_STRUCT_X;

architecture STRUCTURAL of MUX21_STRUCT_X is

component MUX21_STRUCT 
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		S:	In	std_logic;
		Y:	Out	std_logic);
end component;

signal A_cable,B_cable,Y_cable:std_logic_vector(Numbit-1 downto 0);
begin
cables_mux_2_1generic:for I in 0 to NumBit-1 generate  --this cycle permits us te create a generic mux using structural arquitecture
		cablesgen:MUX21_STRUCK
			Port Map(A_cable(I),B_cable(I),S,Y_cable(I));

end generate;

end STRUCTURAL;
