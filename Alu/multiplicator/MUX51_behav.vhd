library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic


entity MUX51_behav is
	generic(N_BIT:integer);
	Port (	A:	In	std_logic_vector(N_bit*2-1 downto 0); --0
		B:	In	std_logic_vector(N_bit*2-1 downto 0); --A
		C:	In	std_logic_vector(N_bit*2-1 downto 0);-- -A
		D:	In	std_logic_vector(N_bit*2-1 downto 0);-- 2A
		E:	In	std_logic_vector(N_bit*2-1 downto 0);-- -2A

		S:	In	std_logic_vector(2 downto 0);
		Y:	Out	std_logic_vector(N_bit*2-1 downto 0));
end MUX51_behav;


architecture BEHAVIORAL of MUX51_behav is-- we use a behavioral in order to define the values that we need 

begin
	pmux: process(A,B,S)
	begin
		if (S="000" or S="111")  then
			Y <= A;-- for 0
		end if;
		if (S="001" or S="010")  then
			Y <= B;-- for A
		end if;
		if S="011"   then
			Y <= D;-- for 2A
		end if;
		if S="100"   then
			Y <= E;-- for -2A
		end if;

		
		if (S="101" or S="110")  then
			Y <= C; --  for -A
		end if;

	end process;

end BEHAVIORAL;



