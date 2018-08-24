library IEEE;

use IEEE.std_logic_1164.all;
use WORK.constants.all;

entity TBMUX21_STRUCT_GENERIC is
end TBMUX21_STRUCT_GENERIC;

architecture TEST_STRUCT of TBMUX21_STRUCT_GENERIC is

        constant NBIT: integer :=16; 
	signal	A1:	std_logic_vector(NBIT-1 downto 0);
	signal	B1:	std_logic_vector(NBIT-1 downto 0);
	signal	S1:	std_logic;
	signal	output1:	std_logic_vector(NBIT-1 downto 0);
	signal	output2:	std_logic_vector(NBIT-1 downto 0);
	
component MUX21_STRUCT_GENERIC 
	GENERIC( N_BIT:INTEGER:=16;DELAY_MUX: Time:= tp_mux);
	PORT(
		A:IN std_logic_vector(N_BIT-1 downto 0);
		B:IN std_logic_vector(N_BIT-1 downto 0);
		S:IN std_logic;
		Y:OUT std_logic_vector(N_BIT-1 downto 0));
   end component;

begin 
		
	U1 : MUX21_STRUCT_GENERIC
	Generic Map (NBIT, 3 ns)
	Port Map ( A1, B1, S1, output1); 

	U2 : MUX21_STRUCT_GENERIC
	Generic Map (NBIT)
	Port Map ( A1, B1, S1, output2); 



		A1 <= "0000000100000001";
		B1 <= "1000000000000001";
		S1 <= '0', '1' after 10 ns;


end TEST_STRUCT;

