library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all;

entity sum_generator is
	generic(N_BIT:integer;NumBit:integer;CBIT:integer);
	port(
	     A:in std_logic_vector (NumBit-1 downto 0);
	     B:in std_logic_vector (NumBit-1 downto 0);
	     CIN:in std_logic_vector (CBIT-1 downto 0);
	     SUM:out std_logic_vector (NumBit-1 downto 0)
	    );

end sum_generator;

architecture structural of sum_generator is

signal i :integer;
component carry_select 
	generic (DRCAS : 	Time := 0 ns;
	         DRCAC : 	Time := 0 ns;
		 N_BIT: integer);
	port(	A: in std_logic_vector (N_BIT-1 downto 0);
		B: in std_logic_vector (N_BIT-1 downto 0);
		CIN: in std_logic;
		SUM: out std_logic_vector (N_BIT-1 downto 0)
		);

end component;

begin
	carry:for i in CBIT downto 1 generate -- use a loop with the numer of carries that instantiate all the needed carry selects.
		carrys:carry_select
			generic map(DRCAS,DRCAC,N_BIT)
			Port Map(A((N_BIT*I)-1 downto N_BIT*(I-1)),B((N_BIT*I)-1 downto N_BIT*(I-1)),CIN(I-1),SUM((N_BIT*I)-1 downto N_BIT*(I-1)));
	end generate;
end STRUCTURAL;
