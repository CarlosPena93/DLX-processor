library IEEE;
use IEEE.std_logic_1164.all; 

entity FD is --is used for each register individualy
	GENERIC(Numbit:integer);
	Port (	D:	In	std_logic_vector(Numbit-1 downto 0);
		CK:	In	std_logic;
		EN_IN:	In	std_logic;
		EN_OUT1:In	std_logic;
		EN_OUT2:In	std_logic;
		RESET:	In	std_logic;
		Q1:	Out	std_logic_vector(Numbit-1 downto 0);-- have differents output for Dout1 and Dout2
		Q2:	Out	std_logic_vector(Numbit-1 downto 0)
	);
end FD;


architecture PIPPO of FD is -- flip flop D with syncronous reset
signal Q:std_logic_vector(Numbit-1 downto 0):=(others=>'0');  
begin
	PSYNCH: process(CK,RESET,EN_IN,EN_OUT1,EN_OUT2)
	begin
	  if CK 'event and CK='1' then -- positive edge triggered:
		
	    if RESET='1' then -- active high reset 
	      Q <= (others=>'0');    
	    elsif EN_IN='1' then-- depending on the  signal that activates the register it does diferents thinks like saving a vaue
	      Q <= D; 
	    elsif EN_OUT1='1' then-- output through the DOut1
	      Q1 <= Q;
	    elsif EN_OUT2='1' then-- output through the DOut2
	      Q2 <= Q; -- input is written on output
	    end if;
	  end if;
	end process;

end PIPPO;



