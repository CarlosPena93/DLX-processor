library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; -- we need a conversion to unsigned 

entity TBp4_32 is 
end TBp4_32; 

architecture TESTp4_32 of TBP4_32 is

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
	     Cout:out std_logic;
	     SUM:out std_logic_vector (NumBit-1 downto 0)
	    );

end component;


  constant Period: time := 1 ns; -- Clock period (1 GHz)
  signal CLK : std_logic :='0';
  signal RESET,LD,EN,ZERO_D : std_logic;
  signal DIN, PRN : std_logic_vector(15 downto 0);
  signal Cin,Cout : std_logic;

  signal A, B, S: std_logic_vector(31 downto 0);
  --signal Ci, Co1, Co2, Co3 : std_logic;

Begin

UADDER1: SumP4  
	   generic map (N_BIT => 4, NumBit => 32, CBIT => 8) 
	   port map (A, B,Cin,Cout, S); 




-- Forcing adder input to LFSR output
  Cin <= '1','0'after 30 ns;
  A(0)<= PRN(15);A(6)<= PRN(15);A(12)<= PRN(15);A(18)<= PRN(15);A(24)<= PRN(15);A(30) <= PRN(0);
  A(1)<= PRN(6);A(7)<= PRN(6);A(13)<= PRN(6);A(19)<= PRN(6);A(25)<= PRN(6);A(31) <= PRN(6);
  A(2)<= PRN(10);A(8)<= PRN(10);A(14)<= PRN(10);A(20)<= PRN(10);A(26) <= PRN(10);
  A(3)<= PRN(4);A(9)<= PRN(4);A(15)<= PRN(4);A(21)<= PRN(4); A(27)<= PRN(4);
  A(4)<= PRN(8);A(10)<= PRN(8);A(16)<= PRN(8);A(22)<= PRN(8);A(28) <= PRN(8);
  A(5)<= PRN(2);A(11)<= PRN(2);A(17)<= PRN(2);A(23)<= PRN(2);A(29) <= PRN(2);
  
 
  
  
  B(0)<= PRN(15);B(6)<= PRN(15);B(12)<= PRN(15);B(18)<= PRN(15);B(24)<= PRN(15);B(30) <= PRN(15);
  B(1)<= PRN(9); B(7)<= PRN(9); B(13)<= PRN(9); B(19)<= PRN(9);B(25) <= PRN(9);B(31) <= PRN(9);
  B(2)<= PRN(5);B(8)<= PRN(5);B(14)<= PRN(5);B(20)<= PRN(5);B(26)<= PRN(5);
  B(3)<= PRN(11);B(9)<= PRN(11);B(15)<= PRN(11);B(21)<= PRN(11); B(27) <= PRN(11);
  B(4)<= PRN(7);B(10)<= PRN(7);B(16)<= PRN(7);B(22)<= PRN(7);B(28) <= PRN(7);
  B(5)<= PRN(13);B(11)<= PRN(13);B(17)<= PRN(13);B(23)<= PRN(13);B(29)<= PRN(13);
  
  
 
  

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

end TESTp4_32;
