library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all;

entity nand_32 is 
	generic(NumBit:integer);-- numbit is 32 bits
	port(
		A: in std_logic_vector(NumBit-1 downto 0);
		B: in std_logic_vector(NumBit-1 downto 0);
		output: out std_logic_vector(CBIT-2 downto 0)) ; --we dont use cin0
end nand_32;

architecture structural of nand_32 is

signal cascade_1: std_logic_vector(31 downto 0);
signal cascade_2: std_logic_vector(15 downto 0);
signal cascade_3: std_logic_vector(7 downto 0);
signal cascade_4: std_logic_vector(3 downto 0);
signal cascade_5: std_logic_vector(1 downto 0);

	
begin
	
	loop1: for I in 0 to 31  generate
			cascade_1(I)<=A(I) nand B(I);
	end generate;
	
	

	loop1: for I in 0 to 31  generate
			cascade_2(I)<=cascade_1(I) nand ;
	end generate;

	loop1: for I in 0 to 7  generate
			cascade_3(I)<=cascade_2(I) nand cascade_2(I+1);
	end generate;

	loop1: for I in 0 to 3  generate
			cascade_4(I)<=cascade_3(I) nand cascade_3(I+1);
	end generate;

	loop1: for I in 0 to 1  generate
			cascade_5(I)<=cascade_4(I) nand cascade_4(I+1);
	end generate;

	output<= cascade_5(0)nand cascade_5(1);	     

end structural;
