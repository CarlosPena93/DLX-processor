library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;


entity RCA_STRUCT is 
	generic (DRCAS :Time;DRCAC :Time;N_BIT :INTEGER );
	Port (	A:	In	std_logic_vector(N_BIT-1 downto 0);
		B:	In	std_logic_vector(N_BIT-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N_BIT-1 downto 0);
		Co:	Out	std_logic);
end RCA_STRUCT; 

architecture STRUCTURAL of RCA_STRUCT is

  signal STMP : std_logic_vector(N_BIT-1 downto 0);
  signal CTMP : std_logic_vector(N_BIT downto 0);

  component FA 
  generic (DFAS : 	Time := 0 ns;
           DFAC : 	Time := 0 ns);
  Port ( A:	In	std_logic;
	 B:	In	std_logic;
	 Ci:	In	std_logic;
	 S:	Out	std_logic;
	 Co:	Out	std_logic);
  end component; 

begin

  CTMP(0) <= Ci;
  S <= STMP;
  Co <= CTMP(N_BIT);
  
  ADDER1: for I in 0 to N_BIT-1 generate
    FAI : FA 
	  generic map (DFAS => DRCAS, DFAC => DRCAC) 
	  Port Map (A(I), B(I), CTMP(I), STMP(I), CTMP(I+1)); 
  end generate;

end STRUCTURAL;


