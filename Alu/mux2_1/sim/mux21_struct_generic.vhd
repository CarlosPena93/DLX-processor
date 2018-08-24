library IEEE;
use IEEE.std_logic_1164.all;
use WORK.constants.all;

entity MUX21_STRUCT_GENERIC is
	GENERIC( N_BIT:INTEGER;DELAY_MUX: Time:= tp_mux);
	PORT(
		A:IN std_logic_vector(N_BIT-1 downto 0);
		B:IN std_logic_vector(N_BIT-1 downto 0);
		S:IN std_logic;
		Y:OUT std_logic_vector(N_BIT-1 downto 0));
   end MUX21_STRUCT_GENERIC;


architecture STRUCTURAL of MUX21_STRUCT_GENERIC is
    signal i :integer;
	component MUX21_STRUCT
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		S:	In	std_logic;
		Y:	Out	std_logic);
	end component;
begin
	MUX:for i in N_BIT-1 downto 0 generate
		MUXES:MUX21_STRUCT
			Port Map(A(i),B(i),S,Y(i));
	end generate;
end STRUCTURAL;


