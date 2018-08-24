library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all;

entity PROPAGATE is -- general propagate
	generic(N_BIT:integer);
	port(
		A: in std_logic_vector(N_bit-1 downto 0);-- depends on the divition of the adder
		B: in std_logic_vector(N_bit-1 downto 0);
		Pout: out std_logic);
end PROPAGATE;


architecture structural of PROPAGATE  is

	signal psignal :std_logic_vector(N_bit-1 downto 0);
	signal Interm_Signal:std_logic_vector(N_bit downto 0);-- used for the acumulation of values
	
	begin 
	Interm_Signal(0)<='1';

	
	xors:for I in 0 to N_bit-1 generate
		psignal(I)<=A(I) xor B(I);-- calculate for each bit the xbr and saved it on psignal
        end generate;

	intermedio:for I in 1 to N_bit generate
		Interm_signal(I)<=Interm_Signal(I-1) and psignal(I-1);-- make an and to all the values calculated in the previous loop and acumulate
	end generate;
	Pout<= Interm_signal(N_bit);-- take the last value of the acumulation.

end structural;

