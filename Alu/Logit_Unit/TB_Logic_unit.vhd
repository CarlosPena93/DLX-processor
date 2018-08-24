library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; -- we need a conversion to unsigned 

entity TB_Logic_unit is 
	generic(NumBit:integer:=2);
end TB_Logic_unit; 

architecture TEST_logic_unit of TB_Logic_unit is

component Logic_Unit 
	generic(NumBit:integer);-- numbit is 32 bits
	port(
		A: in std_logic_vector(NumBit-1 downto 0);
		B: in std_logic_vector(NumBit-1 downto 0);
		Operation: in std_logic_vector(3 downto 0);
		output: out std_logic_vector(Numbit-1 downto 0)) ; --we dont use cin0
end component;

signal A, B,output: std_logic_vector(NumBit-1 downto 0);
signal operation:std_logic_vector(3 downto 0);

Begin

LUconect: Logic_Unit 
	   generic map (NumBit) 
	   port map (A, B,operation, output);

 
A<="00","01"after 3 ns,"00" after 7 ns, "01" after 9 ns, "00" after 11 ns;
B<="00","01" after 6 ns, "00" after 7 ns, "01" after 10 ns;

operation<="0001","1001" after 8 ns; 
end TEST_logic_unit;
