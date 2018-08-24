library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.Numeric_Std.all;
use WORK.constants.all;

entity TBREGISTERFILE_GENERIC is
end TBREGISTERFILE_GENERIC;

architecture TESTA of TBREGISTERFILE_GENERIC is
	
       signal CLK: std_logic := '0';
       signal RESET: std_logic;
       signal ENABLE: std_logic;
       signal RD1: std_logic;
       signal RD2: std_logic;
       signal WR: std_logic;
       signal ADD_WR: std_logic_vector(log2(n_bit) downto 0);
       signal ADD_RD1: std_logic_vector(log2(n_bit) downto 0);
       signal ADD_RD2: std_logic_vector(log2(n_bit) downto 0);
       signal DATAIN: std_logic_vector(data_bit-1 downto 0);
       signal OUT1: std_logic_vector(data_bit-1 downto 0);
       signal OUT2: std_logic_vector(data_bit-1 downto 0);

component registerfile_generic
generic(n_bit:integer;data_bit:integer);
 port ( CLK: 		IN std_logic;
         RESET: 	IN std_logic;
	 ENABLE: 	IN std_logic;
	 RD1: 		IN std_logic;
	 RD2: 		IN std_logic;
	 WR: 		IN std_logic;
	 ADD_WR: 	IN std_logic_vector(log2(n_bit) downto 0);
	 ADD_RD1: 	IN std_logic_vector(log2(n_bit) downto 0);
	 ADD_RD2: 	IN std_logic_vector(log2(n_bit) downto 0);
	 DATAIN: 	IN std_logic_vector(data_bit-1 downto 0);
         OUT1: 		OUT std_logic_vector(data_bit-1 downto 0);
	 OUT2: 		OUT std_logic_vector(data_bit-1 downto 0));
	
	end component;

begin 

RG:registerfile_generic
generic map(n_bit => n_bit, data_bit => data_bit)
PORT MAP (CLK,RESET,ENABLE,RD1,RD2,WR,ADD_WR,ADD_RD1,ADD_RD2,DATAIN,OUT1,OUT2);

	RESET <= '1','0' after 5 ns;
	ENABLE <= '0','1' after 3 ns, '0' after 10 ns, '1' after 15 ns;
	WR <= '0','1' after 6 ns, '0' after 7 ns, '1' after 10 ns, '0' after 20 ns;
	RD1 <= '1','0' after 5 ns, '1' after 13 ns, '0' after 20 ns; 
	RD2 <= '0','1' after 17 ns;
	ADD_WR <= "010110", "001000" after 9 ns;
	ADD_RD1 <="010110", "001000" after 9 ns;
	ADD_RD2<= "011100", "001000" after 9 ns;
	DATAIN<=(others => '0'),(others => '1') after 8 ns;



	PCLOCK : process(CLK)
	begin
		CLK <= not(CLK) after 0.5 ns;	
	end process;

end TESTA;

---
configuration CFG_TESTRF of TBREGISTERFILE_GENERIC is
  for TESTA
	for RG : registerfile_generic
		use configuration WORK.CFG_RF_BEH;
	end for; 
  end for;
end CFG_TESTRF;
