library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use IEEE.Numeric_Std.all;
use work.myTypes.all;

entity CU_DLX_MP2 is
	generic(MEM_SIZE : integer := 19;--ARRAY FOR THE NUMBER OF FUNCTIONS
		CONTROL_w: integer := 11;--vector containing the configuration of the signal
		FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    		OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    		ALU_OPC_SIZE       :     integer := 2;  -- ALU Op Code Word Size
    		IR_SIZE            :     integer := 32;  -- Instruction Register Size  
		MICROCODE_MEM_SIZE : integer := 32;  -- Microcode Memory Size 27
		INSTRUCTIONS_EXECUTION_CYCLES: integer:=3;
    		RELOC_MEM_SIZE     : integer := 16  -- Microcode Relocation 14
	);
       	port (
              -- FIRST PIPE STAGE OUTPUTS
              EN1    : out std_logic;               -- enables the register file and the pipeline registers
              RF1    : out std_logic;               -- enables the read port 1 of the register file
              RF2    : out std_logic;               -- enables the read port 2 of the register file
              WF1    : out std_logic;               -- enables the write port of the register file
              -- SECOND PIPE STAGE OUTPUTS
              EN2    : out std_logic;               -- enables the pipe registers
              S1     : out std_logic;               -- input selection of the first multiplexer
              S2     : out std_logic;               -- input selection of the second multiplexer
	      ALU_OPCODE: out std_logic_vector(ALU_OPC_SIZE-1 downto 0); 
              --ALU1   : out std_logic;               -- alu control bit
              --ALU2   : out std_logic;               -- alu control bit
              -- THIRD PIPE STAGE OUTPUTS
              EN3    : out std_logic;               -- enables the memory and the pipeline registers
              RM     : out std_logic;               -- enables the read-out of the memory
              WM     : out std_logic;               -- enables the write-in of the memory
              S3     : out std_logic;               -- input selection of the multiplexer
              -- INPUTS
	      OPCODE : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
              FUNC   : in  std_logic_vector(FUNC_SIZE - 1 downto 0); 
	      --IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);              
              Clk : in std_logic;
              Rst : in std_logic);                  -- Active Low
end CU_DLX_MP2;

architecture dlx_cu_rtl of CU_DLX_MP2 is

  type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CONTROL_w - 1 downto 0);--the memorie type that has the diferent instructions
  type reloc_mem_array is array (0 to RELOC_MEM_SIZE - 1) of integer;-- an additional memory which has the address of the instructions in the memory array
signal uPC : integer range 0 to 131072;
signal ICount : integer range 0 to INSTRUCTIONS_EXECUTION_CYCLES;
signal cw  : std_logic_vector(control_w - 1 downto 0); -- full control word read from cw_mem
signal OpCode_Reloc : integer;-- index of the memory instruction using the reloc mem
signal IR_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
signal IR_func : std_logic_vector(FUNC_SIZE-1 downto 0);   -- Func part of IR when Rtype
signal aluOpcode_i: std_logic_vector(ALU_OPC_SIZE-1 downto 0):=(others=>'0'); -- ALUOP defined in package

signal reloc_mem : reloc_mem_array := (1,  -- All R-Type Instructions are not Relocated  son las directiones de las instrucciones en la memoria  estan en hexadecimal                                          
                                        4,-- Itype ADDI1
                                        4,--Itype SUBI1
					4,-- Itype AndI1
                                        4,--Itype ORI1
					7,-- Itype ADDI2
                                        7,-- Itype subI2
					7,-- Itype andI2
                                        7,--Itype orI2
					10,-- Itype mov
                                        13,-- SREG1 R2,INP1
					16,--ITYPE SREG2 R2,INP2
                                        19,-- Smem2
					22,-- Lmem1
                                        25,-- Lmem2
                                        0
					);
signal microcode : mem_array := ("00000000000", --reset

				 "11100000000",--RTYPE the only signal that changes are the alu so this control signals are the same for all
				 "00010100000", 
		                 "00000000011",
				 
				
		                 "11100000000", -- Itype ADDI1 and all others 
				 "00000100000",
		                 "00000000011",

				 "11100000000", -- Itype ADDI2 and all others
				 "00011100000",
		                 "00000000011",
		
				 "11100000000", -- Itype MOV
				 "00000100000",
		                 "00000000011",
		
				 "00100000000", --ITYPE SREG1 R2,INP1
				 "00000100000",
		                 "00000000011",
			
				 "00100000000", --ITYPE SREG2 R2,INP2   assume that the input1 is 0  and do a sum
				 "00011100000",
		                 "00000000011",

				 "11100000000", --SMEM2
				 "00011101100",
		                 "00000000011",

				 "11100000000", --LMEM1
				 "00001101100",
		                 "00000010100",
				
				 "11100000000", --LMEM2
				 "00011101100",
		                 "00000010100",
			
				 "00000000000", --free space
				 "00000000000",
		                 "00000000000",
				
				 "00000000000" --free space
				 ); 



begin

cw <= microcode(uPC);-- the control vector cw depends on the uPC
ALU_OPCODE <= aluOpcode_i;
OpCode_Reloc <= reloc_mem(conv_integer(IR_opcode));--the opcode reloc takes the content in the reloc mem given by the opcode

IR_opcode<= OPCODE;
  IR_func<= FUNC;
  -- stage one control signals
  RF1<= cw(control_w - 1);
  RF2<= cw(control_w - 2);
  EN1<= cw(control_w - 3);
  -- stage two control signals
  S1<= cw(control_w - 4);
  S2<= cw(control_w - 5);
  EN2<= cw(control_w - 6);
  -- stage three control signals
  RM<= cw(control_w - 7);
  WM <= cw(control_w - 8);
  EN3<= cw(control_w - 9);
  S3 <= cw(control_w - 10);
  WF1 <= cw(control_w - 11);

ALU_OP_CODE_P : process (IR_opcode, IR_func)-- process that control the alu control signals
   begin  -- process ALU_OP_CODE_P
	case conv_integer(unsigned(IR_opcode)) is
	        -- case of R type requires analysis of FUNC
		when 0 =>
			case conv_integer(unsigned(IR_func)) is
				when 0 => aluOpcode_i <= "00"; -- add
				when 1 => aluOpcode_i <= "01";--sub
				when 2 => aluOpcode_i <= "10"; --AND
				when 3 => aluOpcode_i <= "11"; -- OR  
				when others => aluOpcode_i <= (others=>'0');
			end case;
		when 1 => aluOpcode_i <= "00";-- ADDI1
		when 2 => aluOpcode_i <= "01"; --SUBI1
		when 3 => aluOpcode_i <= "10"; --ANDI1
		when 4 => aluOpcode_i <= "11";--ORI1
		when 5 => aluOpcode_i <= "00";-- ADDI2
		when 6 => aluOpcode_i <= "01"; --SUBI2
		when 7 => aluOpcode_i <= "10";-- andi2
		when 8 => aluOpcode_i <= "11";--ORI2
		when 9 => aluOpcode_i <= "00";-- Itype MOV
		when 10 => aluOpcode_i <= "00";--ITYPE SREG1 R2,INP1
		when 11 => aluOpcode_i <= "00"; --ITYPE SREG1 R2,INP1
		when 12 => aluOpcode_i <= "00"; --SMEM2
		when 13 => aluOpcode_i <= "00"; --LMEM1
		when 14 => aluOpcode_i <= "00"; --LMEM2
		when others => aluOpcode_i <= (others=>'0');

	 end case;
	end process ALU_OP_CODE_P;

  uPC_Proc: process (Clk, Rst)--process that change the upc depending on the clock and on the counter
  begin  -- process uPC_Proc
    if Rst = '0' then                   -- asynchronous reset (active low)
      uPC <= 0;
      ICount <= 0;
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      if (ICount < 1) then
	uPC <= OpCode_Reloc;-- when the counter is 1 its time to change the pointer to a new instruciton 
        ICount <= ICount + 1;
      elsif (ICount < INSTRUCTIONS_EXECUTION_CYCLES) then	
	uPC<=uPC+1;
	ICount <= ICount + 1;
      else--if the counter is superior than 3 then it returns to 1 and the upc also returns to 1
        ICount <= 1;
        uPC <= 1;
      end if;
     end if;
  end process uPC_Proc;

 
end dlx_cu_rtl;
