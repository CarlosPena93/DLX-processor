library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all;


entity DLX is 
	generic(N_BIT:integer;
                N_registers:integer;
                NumBit:integer;
                CBIT:integer;   
                x:integer;
                Inst_mem_size:integer
                MEM_SIZE : integer;--ARRAY FOR THE NUMBER OF FUNCTIONS
		CONTROL_w: integer;--vector containing the configuration of the signal
		FUNC_SIZE:integer;  -- Func Field Size for R-Type Ops
    		OP_CODE_SIZE:integer;  -- Op Code Size
    		ALU_OPC_SIZE:integer;  -- ALU Op Code Word Size
    		IR_SIZE:integer;  -- Instruction Register Size  
		MICROCODE_MEM_SIZE : integer;  -- Microcode Memory Size 27
		INSTRUCTIONS_EXECUTION_CYCLES: integer;
    		RELOC_MEM_SIZE:integer  -- Microcode Relocation 14
        );
	port(
                WR_inst_mem: IN std_logic;-- used for the instruction memory
                ADD_WR_inst_mem: IN std_logic_vector(n_bit downto 0);-- used for the instruction memory                
                CK: in std_logic;
                RESET:in std_logic;
end DLX;

architecture structural of DLX is

component CU_DLX_MP2 
	generic(MEM_SIZE : integer := 19;--ARRAY FOR THE NUMBER OF FUNCTIONS
		CONTROL_w: integer := 22;--vector containing the configuration of the signal
		FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    		OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    		ALU_OPC_SIZE       :     integer := 7;  -- ALU Op Code Word Size
    		IR_SIZE            :     integer := 32;  -- Instruction Register Size  
		MICROCODE_MEM_SIZE : integer := 32;  -- Microcode Memory Size 27
		INSTRUCTIONS_EXECUTION_CYCLES: integer:=5;
    		RELOC_MEM_SIZE     : integer := 16  -- Microcode Relocation 14
	);
       	port (
              -- FIRST PIPE STAGE OUTPUTS
              EN1    : out std_logic;               -- enables the NPC the IR
              WR_inst: out std_logic;               -- Write instruction mem
              RD_inst: out std_logic;               -- Read instruction mem
              enable_inst_mem: out std_logic;       -- enables the instruction mem
        
              -- SECOND PIPE STAGE OUTPUTS
              
              RF1    : out std_logic;               -- enables the read port 1 of the register file
              RF2    : out std_logic;               -- enables the read port 2 of the register file
              WF1    : out std_logic;               -- enables the write port of the register file
              EN2    : out std_logic;               -- enables the pipe registers
          
              --THIRD PIPE STAGE OUTPUTS
          
              S1     : out std_logic;               -- input selection of the first multiplexer
              S2     : out std_logic;               -- input selection of the second multiplexer
	      ALU_OPCODE: out std_logic_vector(ALU_OPC_SIZE-1 downto 0); 
              EN3    : out std_logic;              -- enables the Alu register
          
              --ALU1   : out std_logic;               -- alu control bit
              --ALU2   : out std_logic;               -- alu control bit
              -- FORTH PIPE STAGE OUTPUTS
          
              EN4    : out std_logic;               -- enables the memory and the pipeline registers
              RM     : out std_logic;               -- enables the read-out of the memory
              WM     : out std_logic;               -- enables the write-in of the memory
          
              --FIFHT PIPE STAGE OUTPUTS
              S3     : out std_logic;              -- input selection of the multiplexer
              -- INPUTS
	      OPCODE : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
              FUNC   : in  std_logic_vector(FUNC_SIZE - 1 downto 0); 
	      --IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);              
              Clk : in std_logic;
              Rst : in std_logic);                  -- Active Low
end component;

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


component memory_generic
 generic(n_bit:integer;data_bit:integer);
 port (
        RESET: 	IN std_logic;
	 ENABLE: 	IN std_logic;
	 RD: 		IN std_logic;
	 WR: 		IN std_logic;
	 ADD_WR: 	IN std_logic_vector(n_bit downto 0);
	 ADD_RD1: 	IN std_logic_vector(n_bit downto 0);
	 DATAIN: 	IN std_logic_vector(data_bit-1 downto 0);
         OUT1: 		OUT std_logic_vector(data_bit-1 downto 0);
end component;

component instruction_mem 
 generic(n_bit:integer;data_bit:integer);
 port (
         RESET: 	IN std_logic;
	 ENABLE: 	IN std_logic;
	 RD: 		IN std_logic;
         WR: 		IN std_logic;
	 ADD_WR: 	IN std_logic_vector(n_bit downto 0);
	 ADD_RD1: 	IN std_logic_vector(n_bit downto 0);
	 DATAIN: 	IN std_logic_vector(data_bit-1 downto 0);
         OUT1: 		OUT std_logic_vector(data_bit-1 downto 0);
end component;


component ALU 
		generic(N_BIT:integer;NumBit:integer;CBIT:integer;x:integer;Multip_N_bit;integer;grain_number:integer;small_grain:integer);
	port(
		A: in std_logic_vector(NumBit-1 downto 0);
		B: in std_logic_vector(NumBit-1 downto 0);
		Control: in std_logic_vector(6 downto 0); -- two MSB for the selection of the block and 4 LSB for the operation of the block
		Output: out std_logic_vector(NumBit-1 downto 0));

end component;

component FD  --is array of flipflops for the register
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
end component;

component MUX21_STRUCT_X 
	generic(NumBit:integer);
	Port (	A:	In	std_logic_vector(Numbit-1 downto 0);
		B:	In	std_logic_vector(Numbit-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(Numbit-1 downto 0););
end component;


component FF_ARRAY  --Array of flipflops 
	GENERIC(Numbit:integer);
	Port (	D:	In	std_logic_vector(Numbit-1 downto 0);
		CK:	In	std_logic;
		RESET:	In	std_logic;
                ENABLE: In      std_logic;
		Q:	Out	std_logic_vector(Numbit-1 downto 0);--
	);
end component;




----------signals for instruction mem:

signal WR_inst,RD_inst,enable_inst_mem,:std_logic;
signal add_Rd_inst,add_Wr_inst:std_logic_vector(Inst_mem_size-1 downto 0);
signal datain_inst,out1_inst:std_logic_vector(Numbit-1 downto 0);

----------signals for register file:

signal Enable_reg,RF1,RF2,WR1,:std_logic;-- control signals for the registerfile
signal data_input_RF,regA,regB:std_logic_vector(Numbit-1 downto 0);

-----------------signals for muxes:

signal Smux1,Smux2,Smux3:std_logic;
signal Out_mux1,Out_mux2,Out_mux3:std_logic_vector(numbit-1 downto 0);

-------------------signals for ALU

signal ALU_Control: std_logic_vector(6 downto 0);
signal ALU_Output,alu_reg: std_logic_vector(NumBit-1 downto 0);

-------------------signals for data memory:

signal enable_data_mem, RD_Data,WR_Data :std_logic;
signal Data_input,output_data,output_data_reg: std_logic_vector(NumBit-1 downto 0);



--------------------general signals:

----instrucion separation:
signal instruction: std_logic_Vector(Numbit-1 downto 0);
signal opcode: std_logic_vector(5 downto 0); --6 bits opcode;
signal Rs1,Rs2,Rd:std_logic_vector(4 downto 0);--5 bits for the register
signal immediate2:std_logic_vector(Numbit-1 downto 0); --32 bits for hte immediate
signal func:std_logic_vector(10 downto 0);
signal RD1_C,RD2_C:std_logic_vector(Numbit-1 downto 0);

---
signal  ADD_Wr_feed_Back std_logic_Vector(log2(N_registers) downto 0);


signal PC: std_logic_Vector(Numbit-1 downto 0):= (others=>'0');
signal four:std_logic_Vector(Numbit-1 downto 0);
signal immediate1,sum4:std_logic_vector(Numbit-1 downto 0); --16 bits for hte immediate
	
------------signals for the flipflops:

signal EN1,EN2,EN3,EN4:std_logic_vector;
begin


    four(2 downto 0)<="100";
    four(numbit-1 downto 3)<=(others=>'0');

    opcode<=instruction(numbit-1 downto numbit-6);
    Rs1<=instruction(numbit-7 downto numbit-11);
    Rs2<=instruction(numbit-12 downto numbit-16);
    Rd<=instruction(numbit-17 downto numbit-21);
    immediate2(Numbit-17 downto 0)<=instruction(Numbit-17 downto 0);
    immediate2(Numbit-1 downto numbit-16)<=(others=>'0');-- for extending the value
    

    
    instruction_register:FF_ARRAY
                generic map(Numbit);
                port map (Out1_inst,CK,RESET,EN1,instruction);
        
    NewPC_register:FF_ARRAY
                generic map(Numbit);
                port map (sum4,CK,RESET,EN1,immediate1);
        
        
          
    ALU_register:FF_ARRAY
                generic map(Numbit);
                port map (Alu_output,CK,RESET,Alu_reg);
        
    Register_B:FF_ARRAY
                generic map(Numbit);
                port map (regB,CK,RESET,Data_input);
    RD1:FF_ARRAY
                generic map(Numbit);
                port map (RD,CK,RESET,EN2,RD1_c);
    RD2:FF_ARRAY
                generic map(Numbit);
                port map (RD1_c,CK,RESET,EN3,ADD_Wr_feed_Back);
        
    LMD:FF_ARRAY
                generic map(Numbit);
                port map (output_data,CK,RESET,EN4,Output_data_reg);
    
        
     adder:Sump4-- there is one decoder for write addres and 2 for read adress
                    generic map(N_BIT,NumBit,CBIT);
                    port map (PC,Four,'0',,sum4);-- the LSB of operation control the Cin remember 0 is for addition and 1 is for substraction
            
    Inst_memory:instruction_mem -- there is one decoder for write addres and 2 for read adress
                    generic map(Inst_mem_size,numbit);-- me falta definir esto
                    port map (RESET,enable_inst_mem,RD_inst,WR_inst,add_Wr_inst,add_RD_ins,Datain_inst,out1_inst);-- the LSB of operation control the Cin remember 0 is for addition and 1 is for substraction
        
        
    register_file:registerfile_generic
                generic map (N_registers,Numbit);
                port map(CK,RESET,enable_reg,RF1,RF2,Wr1,ADD_Wr_feed_Back,RS1,RS2,data_input_RF,regA,regB);
        
    
    mux1:MUX21_STRUCT_X 
                    generic map(Numbit);
                    port map(immediate1,regA,Smux1,Out_mux1);
    
    mux2:MUX21_STRUCT_X 
                    generic map(Numbit);
                    port map(immediate2,regB,Smux2,Out_mux2);
    
    ALU_BLOCK:ALU
                    generic map(N_Bit,Numbit,Cbit,x,Multip_N_Bit,grain_number,small_grain);
                    port map(Out_mux1,Out_mux2,alu_control,Alu_output);



     data_memory:memory_generic -- there is one decoder for write addres and 2 for read adress
                    generic map(Numbit,numbit);-- me falta definir esto
                    port map (RESET,enable_data_mem,RD_data,WR_data,Alu_reg,Alu_reg,Data_input,output_data);-- the LSB of operation control the Cin remember 0 is for addition and 1 is for substraction


     mux3:MUX21_STRUCT_X 
                    generic map(Numbit);
                    port map(output_data_reg,Alu_reg,Smux3,data_input_RF);
            
    Microcode_control:CU_DLX_MP2
                    generic map(MEM_SIZE,CONTROL_W,FUNC_SIZE,OP_CODE_SIZE,ALU_OPC_SIZE,IR_SIZE,MICROCODE_MEM_SIZE,INSTRUCTION_EXECUTION_CYCLES,RELOC_MEM_SIZE);
                    port map(EN1,WR_inst,Rd_inst,enable_inst_mem,RF1,RF2,WR1,EN2,SMUX1,SMUX2,Alu_control,EN3,EN4,RD_Data,Wr_Data,Smux3,opcode,func,CK,RESET);
 
            

end structural;
