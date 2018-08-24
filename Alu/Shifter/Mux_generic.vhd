library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use IEEE.std_logic_unsigned.all;
use IEEE.Numeric_Std.all;
use WORK.constants.all;

entity MUX_generic is
	generic(NumBit:integer;Inputs:integer);
	Port (	Input:	In	std_logic_vector(Numbit*Inputs-1 downto 0); 
		S:	In	std_logic_vector(log2(Inputs)-1 downto 0);
                reset: In std_logic;
		Outputs:	Out	std_logic_vector(Numbit-1 downto 0));
end MUX_generic;


architecture BEHAVIORAL of MUX_generic is-- we use a behavioral in order to define the values that we need 

type matrix_mux is array (inputs-1 downto 0) of std_logic_vector(Numbit-1 downto 0);

signal inputs_cable:matrix_mux;
signal ainteger:integer;

begin 
    conections:for I in 0 to  Inputs-1   generate
                  conections_2: for X in 0 to Numbit-1 generate
                        	inputs_cable(I)(X)<=input(I*NumBit+X);
                  end generate;
               end generate;
           
ainteger <= to_integer(unsigned(S));	

Outputs<=(Inputs_cable(ainteger));


end BEHAVIORAL;
	
