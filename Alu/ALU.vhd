library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all;


entity ALU is 
	generic(N_BIT:integer;NumBit:integer;CBIT:integer;x:integer;Multip_N_bit;integer;grain_number:integer;small_grain:integer);
	port(
		A: in std_logic_vector(NumBit-1 downto 0);
		B: in std_logic_vector(NumBit-1 downto 0);
		Control: in std_logic_vector(6 downto 0); -- two MSB for the selection of the block and 4 LSB for the operation of the block
		Output: out std_logic_vector(NumBit-1 downto 0));
end ALU;

architecture structural of ALU is

component SumP4 is
	generic(N_BIT:integer;NumBit:integer;CBIT:integer);
	port(
	     A:in std_logic_vector (NumBit-1 downto 0);
	     B:in std_logic_vector (NumBit-1 downto 0);
	     Cin: in std_logic;
             cout:out std_logic;
	     SUM:out std_logic_vector (NumBit-1 downto 0)
	    );
end component;

component boothmul is 
	GENERIC( N_BIT:INTEGER);
	port(	A:IN std_logic_vector(N_BIT-1 downto 0);-- we supose A is always positive
		B:IN std_logic_vector(N_BIT-1 downto 0);
		multi:out std_logic_vector(N_BIT*2-1 downto 0)
		);
end component;

component Logic_Unit 
	generic(NumBit:integer);-- numbit is 32 bits
	port(
		A: in std_logic_vector(NumBit-1 downto 0);
		B: in std_logic_vector(NumBit-1 downto 0);
		Operation: in std_logic_vector(3 downto 0);
		output: out std_logic_vector(Numbit-1 downto 0)) ;
end component;

component shifter 
	generic(NumBit:integer;grain_number:integer;small_grain:integer);--
	port(
		R1: in std_logic_vector(NumBit-1 downto 0);
		R2: in std_logic_vector((log2(numbit/grain_number)+log2(small_grain))-1 downto 0);-- because numbit is 32 bits is 4 downto 0
		Config: in std_logic_vector(1 downto 0);-- shift left shift right, aritmetic 
		reset: in std_logic;
		Output: out std_logic_vector(NumBit-1 downto 0));
end component;

component comparator 
	generic(Numbit:integer);
	port(
		Sum: in std_logic_vector(NumBit-1 downto 0);
		Cout: in std_logic;
                operation:in std_logic_vector(2 downto 0);
                Output:out std_logic;
end component;




signal Cout_comparator,comparator_output: std_logic;

signal Logic_output,Multi,sum,shifted_output: std_logic_vector(numbit-1 downto 0);

signal A_multip,B_multip:std_logic_vector(Multip_n_bit-1 downto 0);

signal operation:std_logic_vector(3 downto 0);-- for selecting the operation to be done inside the alu

signal selection:std_logic_vector(2 downto 0);--for selecting the block used on the alu

signal shift_number:std_logic_vector((log2(numbit/grain_number)+log2(small_grain))-1 downto 0);

	
begin


	shift_number<=B((log2(numbit/grain_number)+log2(small_grain))-1 downto 0);


	
	selection<=control(6 downto 4);
	
	operation<=control(3 downto 0);

	A_multip<=A(Multip_n_bit-1 downto 0);

	B_multip<=B(Multip_n_bit-1 downto 0);
	
	adder:Sump4-- there is one decoder for write addres and 2 for read adress
                    generic map(N_BIT,NumBit,CBIT);
                    port map (A,B,operation(0),Cout_comparator,sum);-- the LSB of operation control the Cin remember 0 is for addition and 1 is for substraction
        
        multiplier:boothmul-- there is one decoder for write addres and 2 for read adress
                    generic map(Multip_N_bit);
                    port map (A_multip,B_multip,multi);
    

        LU:Logic_unit-- there is one decoder for write addres and 2 for read adress
                    generic map(NumBit);
                    port map (A,B,operation,Logic_output);


	shifter_block:shifter-- there is one decoder for write addres and 2 for read adress
          	generic map(numbit, Grain_number,Small_grain);
                port map (A,shift_number,operation(1 downto 0),Shifted_output);
        
        
        comparator_block:comparator-- there is one decoder for write addres and 2 for read adress
          	generic map(numbit);
                port map (sum,cout_comparator,operation(2 downto 0),comparator_output);-- operation "000"A=B ---"001"A=>B---"010"A>B---"011"A<B---"100"A<=B
        

	Output <=sum when Selection="000";
	Output <=multi when Selection="001";
	Output <=Logic_ouput when Selection="010";
	Output <=shifted_output when Selection="011";
        output<=comparator_output when selection="100";


end structural;
