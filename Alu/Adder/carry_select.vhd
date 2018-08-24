library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all;

entity carry_select is 
	generic (DRCAS : 	Time := 0 ns;
	         DRCAC : 	Time := 0 ns;
		 N_BIT: integer);
	port(	A: in std_logic_vector (N_BIT-1 downto 0);
		B: in std_logic_vector (N_BIT-1 downto 0);
		CIN: in std_logic;
		SUM: out std_logic_vector (N_BIT-1 downto 0)
		);

end carry_select;

architecture STRUCTURAL of carry_select is

component rca_struct -- use for the sum is the ripple carry adder
	generic (DRCAS : 	Time := 0 ns;
	         DRCAC : 	Time := 0 ns;
		 N_BIT :        INTEGER);
	Port (	A:	In	std_logic_vector(N_BIT-1 downto 0);
		B:	In	std_logic_vector(N_BIT-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N_BIT-1 downto 0);
		Co:	Out	std_logic);
end component;

component MUX21_GENERIC -- use a mux to select the sum
	GENERIC(N_BIT:INTEGER;DELAY_MUX: Time:= tp_mux);
	PORT(
		A:IN std_logic_vector(N_BIT-1 downto 0);
		B:IN std_logic_vector(N_BIT-1 downto 0);
		S:IN std_logic;
		Y:OUT std_logic_vector(N_BIT-1 downto 0));
end component;

signal rca0_out: std_logic_vector(N_BIT-1 downto 0);
signal rca1_out: std_logic_vector(N_BIT-1 downto 0);

begin 

	RCA0:rca_struct -- the first sum with the carry
	generic map(DRCAS,DRCAC,N_BIT)
	port map(A,B,'0',rca0_out);

	RCA1:rca_struct-- the second sum with the carry
	generic map(DRCAS,DRCAC,N_BIT)
	port map(A,B,'1',rca1_out);

	MUX:MUX21_GENERIC-- the mux that is conected to the carry and selects depending on it the sum
	generic map(N_BIT)
	port map(rca1_out,rca0_out,CIN,SUM); 

end STRUCTURAL;
