library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; -- we need a conversion to unsigned 

entity tb_sg is 
end tb_sg; 

architecture TESTSG of tb_sg is

  component LFSR16 
    port (CLK, RESET, LD, EN : in std_logic; 
          DIN : in std_logic_vector(15 downto 0); 
          PRN : out std_logic_vector(15 downto 0); 
          ZERO_D : out std_logic);
  end component;

component sum_generator 
	generic(N_BIT:integer;NumBit:integer;CBIT:integer:=1);
	port(
	     A:in std_logic_vector (NumBit-1 downto 0);
	     B:in std_logic_vector (NumBit-1 downto 0);
	     CIN:in std_logic_vector (CBIT-1 downto 0);
	     SUM:out std_logic_vector (NumBit-1 downto 0)
	    );

end component;

component RCA_STRUCT 
	generic (DRCAS : 	Time := 0 ns;
	         DRCAC : 	Time := 0 ns;
		 N_BIT :        INTEGER := 6);
	Port (	A:	In	std_logic_vector(N_BIT-1 downto 0);
		B:	In	std_logic_vector(N_BIT-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N_BIT-1 downto 0);
		Co:	Out	std_logic);
end component; 

  

  constant Period: time := 1 ns; -- Clock period (1 GHz)
  signal CLK : std_logic :='0';
  signal RESET,LD,EN,ZERO_D : std_logic;
  signal DIN, PRN : std_logic_vector(15 downto 0);

  signal A, B, S: std_logic_vector(5 downto 0);
  signal Ci: std_logic_vector(5 downto 0);
  --signal C: std_logic_vector(5 downto 0);

Begin

-- Instanciate the ADDER without delay in the carry generation
  UADDER1: sum_generator 
	   generic map (N_BIT => 1, NumBit => 6, CBIT => 6) 
	   port map (A, B, Ci, S); 
 
-- Forcing adder input to LFSR output
  Ci(0)<= '0';
  Ci(1)<= A(0)and B(0);
  Ci(2)<= (A(1)and B(1)) or ((A(1) or B(1)) and Ci(1)); 
  Ci(3)<= (A(2)and B(2)) or ((A(2) or B(2)) and Ci(2));
  Ci(4)<= (A(3)and B(3)) or ((A(3) or B(3)) and Ci(3));
  Ci(5)<= (A(4)and B(4)) or ((A(4) or B(4)) and Ci(4));
  --Ci()<= (A(5)and B(5)) or ((A(5) or B(5)) and Ci(4));

  A(0) <= PRN(0);
  A(5) <= PRN(2);
  A(3) <= PRN(4);
  A(1) <= PRN(6);
  A(4) <= PRN(8);
  A(2) <= PRN(10);
  

  B(0) <= PRN(15);
  B(5) <= PRN(13);
  B(3) <= PRN(11);
  B(1) <= PRN(9);
  B(4) <= PRN(7);
  B(2) <= PRN(5);

-- Instanciate the Unit Under Test (UUT)
  UUT: LFSR16 port map (CLK=>CLK, RESET=>RESET, LD=>LD, EN=>EN, 
                        DIN=>DIN,PRN=>PRN, ZERO_D=>ZERO_D);
-- Create the permanent Clock and the Reset pulse
  CLK <= not CLK after Period/2;
  RESET <= '1', '0' after Period;

-- Open file, make a load, and wait for a timeout in case of design error.
  STIMULUS1: process
  begin
    DIN <= "0000000000000001";
    EN <='1';
    LD <='1';
    wait for 2 * PERIOD;
    LD <='0';
    wait for (65600 * PERIOD);
  end process STIMULUS1;

end TESTSG;
