library IEEE;
use IEEE.std_logic_1164.all;
use WORK.constants.all;

entity MUX21_GENERIC is
	GENERIC( N_BIT:INTEGER;DELAY_MUX: Time:= tp_mux);
	PORT(
		A:IN std_logic_vector(N_BIT-1 downto 0);
		B:IN std_logic_vector(N_BIT-1 downto 0);
		S:IN std_logic;
		Y:OUT std_logic_vector(N_BIT-1 downto 0));
   end MUX21_GENERIC;

architecture BEHAVIORAL of MUX21_GENERIC is

begin
	Y <= A when S='1' else B;

end BEHAVIORAL;

architecture STRUCTURAL of MUX21_GENERIC is
    signal i :integer;
	component MUX21
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		S:	In	std_logic;
		Y:	Out	std_logic);
	end component;
begin
	MUX:for i in N_BIT-1 downto 0 generate
		MUXES:MUX21
			Port Map(A(i),B(i),S,Y(i));
	end generate;
end STRUCTURAL;

configuration CFG_MUX21_GENERIC_BEHAVIORAL of MUX21_GENERIC is
	for BEHAVIORAL
	end for;
end CFG_MUX21_GENERIC_BEHAVIORAL;

configuration CFG_MUX21_GENERIC_STRUCTURAL of MUX21_GENERIC is
   for STRUCTURAL
	   for all : MUX21
		   use configuration WORK.CFG_MUX21_STRUCTURAL;
	   end for;
	end for;
end CFG_MUX21_GENERIC_STRUCTURAL;


	
