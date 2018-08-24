library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; -- we need a conversion to unsigned 

entity TBp4_4 is 
end TBp4_4; 

architecture TESTp4_4 of TBP4_4 is

  component LFSR16 
    port (CLK, RESET, LD, EN : in std_logic; 
          DIN : in std_logic_vector(15 downto 0); 
          PRN : out std_logic_vector(15 downto 0); 
          ZERO_D : out std_logic);
  end component;
component SumP4 
	generic(N_BIT:integer;NumBit:integer;CBIT:integer);
	port(
	     A:in std_logic_vector (NumBit-1 downto 0);
	     B:in std_logic_vector (NumBit-1 downto 0);
	     Cin: in std_logic;
	     SUM:out std_logic_vector (NumBit-1 downto 0)
	    );

end component;


  constant Period: time := 1 ns; -- Clock period (1 GHz)
  signal CLK : std_logic :='0';
  signal RESET,LD,EN,ZERO_D : std_logic;
  signal DIN, PRN : std_logic_vector(15 downto 0);
  signal Cin : std_logic;

  signal A, B, S: std_logic_vector(31 downto 0);
  --signal Ci, Co1, Co2, Co3 : std_logic;

Begin

UADDER1: SumP4  
	   generic map (N_BIT => 4, NumBit => 32, CBIT => 8) 
	   port map (A, B,Cin, S); 



A <= "00000000000000000000000000000001","00000000000000000000000000000100" after 5 ns;

B <= "00000000000000000000000000000001","00000000000000000000000000000000" after 3 ns, "00000000000000000000000000000001" after 5 ns;


-- Forcing adder input to LFSR output
  Cin <= '1','0'after 7 ns;
 
  
 
      

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

end TESTp4_4;
