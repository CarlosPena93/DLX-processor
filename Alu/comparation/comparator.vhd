library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all;


entity comparator is 
	generic(Numbit:integer);
	port(
		Sum: in std_logic_vector(NumBit-1 downto 0);
		Cout: in std_logic;
                operation:in std_logic_vector(2 downto 0);
                Output:out std_logic;
		
end comparator;

architecture structural of comparator is

subtype levels is natural range 0 to (log2(Numbit)); -- using natural type
type cascade_matrix is array (levels) of std_logic_vector(numbit-1 downto 0);

signal cables:cascade_matrix;

signal Ncout:std_logic;

signal Output_cables: out std_logic_vector(4 downto 0));--in this order from MSB to LSB <= -  < - > - => - = -



begin
	cables(0)<=sum;
	cascade_levels:for x in 1 to log2(numbit) generate
		adder_input: for i in 0 to (numbit/(2**x))-1 generate
			cables(x)(i)<=cables(X-1)(i*2) Nor cables(X-1)(i*2-1);
		end generate;
	end generate;
    
        
        
    

	Ncout<=not(cout);
	cables(log2(Numbit))

	output_cables(0)<=ncout or cables(log2(Numbit))(0);--=

	output_cables(1)<=ncout;--=>

	output(2)_cables<= (not(cables(log2(Numbit)))) and cout;-->

	output(3)_cables<=cout;--<
	
	output(4)_cables<=cables(log2(Numbit));--<=
	

        Output <=output_cables(0) when Operation="000";
	Output <=output_cables(1) when Operation="001";
	Output <=output_cables(2) when Operation="010";
	Output <=output_cables(3) when Operation="011";
        Output <=output_cables(4) when Operation="100";
    
end structural;
