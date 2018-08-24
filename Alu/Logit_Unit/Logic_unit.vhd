library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
--use WORK.constants.all;

entity Logic_Unit is 
	generic(NumBit:integer);-- numbit is 32 bits
	port(
		A: in std_logic_vector(NumBit-1 downto 0);
		B: in std_logic_vector(NumBit-1 downto 0);
		Operation: in std_logic_vector(3 downto 0);
		output: out std_logic_vector(Numbit-1 downto 0)) ;
end Logic_Unit;

architecture structural of Logic_Unit is

type cables_array is array(3 downto 0) of std_logic_vector(NumBit-1 downto 0); 
signal nand_output,selected_output: cables_array;
signal output_t:std_logic_vector(Numbit-1 downto 0);

signal input,oper:cables_array;



begin
	oper(0)<=(others=>operation(0));-- cables for the operation
	oper(1)<=(others=>operation(1));
	oper(2)<=(others=>operation(2));
	oper(3)<=(others=>operation(3));

	input(0)<=A;
	input(1)<=not(A);
	input(2)<=B;
	input(3)<=not(B);
		
	nand_output(0)<=input(1) and input(3) and oper(0);-- generate 3 inputs and

	nand_output(1)<=input(1) and input(2) and oper(1);

	nand_output(2)<= input(0) and input(3) and oper(2);

	nand_output(3)<= input(0) and input(2) and oper(3);
	
	selected_output(0)<=not nand_output(0); --negate for creating the nand

	selected_output(1)<= not nand_output(1);

	selected_output(2)<= not nand_output(2);

	selected_output(3)<=not nand_output(3);


	output_t<=selected_output(0) and selected_output(1) and selected_output(2) and selected_output(3);

	output<=not output_t;

--------- this was done in this way because the compiler does not accept more than 2 input nand and when done in cascade the behavior of the circuit changed. 

	
	   

end structural;
