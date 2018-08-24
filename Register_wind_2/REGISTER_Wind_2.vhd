library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_Std.all;
use WORK.constants.all;

entity REGISTER_Wind_2 is
	GENERIC(N_BIT:integer;--number of bits per register
		NumReg:integer;--number of registersds
		N:integer;-- N is for lo
		M:integer;
		F:integer); --number of windows
	Port (	Din:	In	std_logic_vector(N_BIT-1 downto 0);
		ADDR:   In	std_logic_vector(2*log2(N*4) downto 0);-- the address of the window decoder and global decoder are in this addr.there are some forbiden adresses. and the mos significant bit defines weather im  using the global or the other types of register
		call_signal:  in std_logic;-- signal given by the control of the processor when a subrutine is called
		ret_signal: 	in std_logic;
		ack_mem:	in std_logic;--signal received from the memorie when all the register are saved
		CLK:		In std_logic;
		ADD_RD1: 	IN std_logic_vector(2*log2(N*4) downto 0);--uses the MSB for defining if it is the global addres or the winded addres.
		ADD_RD2: 	IN std_logic_vector(2*log2(N*4) downto 0);--
		RESET:	In	std_logic;
		Dout1:Out	std_logic_vector(N_BIT-1 downto 0):=(others=>'0');
		Dout2:Out	std_logic_vector(N_BIT-1 downto 0):=(others=>'0');
		MUX_OUT:Out	std_logic_vector(N_BIT-1 downto 0);
		spill_out:     out std_logic;
		fill_out:	out std_logic
	
	);
end REGISTER_Wind_2;

architecture STRUCTURAL of REGISTER_Wind_2 is
   signal i : integer;
	component FD --used for each register
	GENERIC(N_BIT:integer);
	Port (	D:	In	std_logic_vector(N_bit-1 downto 0);
		CK:	In	std_logic;
		EN_IN:	In	std_logic;
		EN_OUT1:In	std_logic;
		EN_OUT2:In	std_logic;
		RESET:	In	std_logic;
		Q1:	Out	std_logic_vector(N_bit-1 downto 0);
		Q2:	Out	std_logic_vector(N_bit-1 downto 0)
	);
        end component;

component tri_state_buffer is
    Port ( 
	   IN6  : in  STD_LOGIC_VECTOR (5 downto 0);
           EN6  : in  STD_LOGIC;
           OUT6 : out STD_LOGIC_VECTOR (5 downto 0));
end component;

component DECODER_BEHAV_GENERIC 
	generic(N_bit:integer);
	Port (	A:	In	std_logic_vector(N_bit-1 downto 0);
		rst:	In	std_logic;
		en:   	in 	std_logic;
		Y:	Out	std_logic_vector(2**N_BIT-1 downto 0));	
end component; 

component DECODER_window 
	generic(N_bit:integer;
		N:integer);
	Port (	A:	In	std_logic_vector(N_bit-1 downto 0);
		rst:	In	std_logic;
		en:   	in 	std_logic;
		Y:	Out	std_logic_vector((3*N)-1 downto 0));
		
end component; 


component rf_control --controls the behavior of the register is a FSM
	generic(f:integer;--Number of windows
		n_bit:integer--numer of bits per register
		);
	port(	
		clk:		in std_logic;
		call_signal,ret_signal: in std_logic;
		reset:		in std_logic;
		ack_mem:	in std_logic;
		spill_out,fill_out:	out std_logic;
		canrestorein:	in std_logic_vector(n_bit-1 downto 0);
		cansavein:	in std_logic_vector(n_bit-1 downto 0);
		canrestoreout:	out std_logic_vector(n_bit-1 downto 0);
		cansaveout:	out std_logic_vector(n_bit-1 downto 0);
		cwp_out:	out std_logic_vector(log2(f)-1 downto 0);--valor del log2(f)
		swp_out:out std_logic_vector(log2(f)-1 downto 0));--log2(f)


end component;


type matrix_demux is array (F-1 downto 0) of std_logic_vector(3*N-1 downto 0);--matrix that represents a demux that activates the diferent resgisters

signal Demux_in,Demux_out1,Demux_out2:matrix_demux;-- signal correspondig to the demux that activates the diferentes registers




signal decoder_out_wind,decoder_out1_wind,decoder_out2_wind :std_logic_vector((3*N)-1 downto 0);-- this signal doesnt take the unvalid address

signal decoder_out_global,decoder_out1_global,decoder_out2_global :std_logic_vector((4*N)-1 downto 0);
signal CWP, SWP,TEMP:std_logic_vector(log2(F)-1 downto 0);

signal ADD_RD1_Winded,ADD_RD1_global:std_logic_vector(log2(4*N)-1  downto 0);-- this signals is for separating the demux of the global registers and of the winded registers
signal ADD_RD2_Winded,ADD_RD2_global:std_logic_vector(log2(4*N)-1  downto 0);
signal ADDR_Winded:std_logic_vector(log2(4*N)-1  downto 0);
signal ADDR_Global:std_logic_vector(log2(4*N)-1  downto 0);

signal ENABLE_IN,ENABLE_OUT1,ENABLE_OUT2 :std_logic_vector(NumReg-1  downto 0):=(others=>'0'); -- the diferents enable for the register

signal cwp_int:integer := 0;
signal spill_out_temp,fill_out_temp: std_logic;
signal can_restore:std_logic_vector(n_bit-1 downto 0);
signal can_save:std_logic_vector(n_bit-1 downto 0);
signal enable_global1,enable_global2,enable_global3,enable_wind1, enable_wind2 ,enable_wind3:std_logic;

signal tristate_enable:std_logic_vector(4*N-1 downto 0);

begin

ADD_RD1_winded<= ADD_RD1(log2(4*N)-1 downto 0);
ADD_RD2_winded<= ADD_RD2(log2(4*N)-1 downto 0);
ADD_RD1_GLObal<= ADD_RD1(2*log2(4*N)-1 downto log2(4*N));
ADD_RD2_GLObal<= ADD_RD2(2*log2(4*N)-1 downto log2(4*N));
ADDR_Winded<= ADDR(log2(4*N)-1 downto 0);--first part of the address is for the decoder of the window there are some addresses than doesnt work in this part	
ADDR_Global<= ADDR(2*log2(4*N)-1 downto log2(4*N));-- second part of the addres is for the decoder of the global


------------creation of the register file using a generate and the number of register---------------------
	REG:for i in NumReg-1 downto 0  generate
		regs:FD
		   generic map(N_bit)--N_bit is the numer of bits
		   Port Map(Din,CLK,ENABLE_IN(i),ENABLE_OUT1(i),ENABLE_OUT2(i),RESET,Dout1,Dout2);
	end generate;


enable_global1<=ADDR(2*log2(N*4));
enable_global2<=ADD_RD1(2*log2(N*4));
enable_global3<=ADD_RD2(2*log2(N*4));
enable_wind1<=not enable_global1;
enable_wind2<=not enable_global2;
enable_wind3<=not enable_global3;
------------decoder for the In locals and out----------------------

	decoder_windows_in:DECODER_window-- there is one decoder for write addres and 2 for read adress
			generic map(log2(4*N),N)
			Port map (ADDR_Winded,RESET,enable_wind1,decoder_out_wind);
	decoder_windows_out1:DECODER_window
			generic map(log2(4*N),N)
			Port map (ADD_RD1_winded,RESET,enable_wind2,decoder_out1_wind);
	decoder_windows_out2:DECODER_window
			generic map(log2(4*N),N)
			Port map (ADD_RD2_winded,RESET,enable_wind3,decoder_out2_wind);


--------------decoder for the global section.--------------------
	
	decoder_GLOBAL_in:DECODER_BEHAV_GENERIC-- same but with globals 
			generic map(log2(4*N)) 
			Port Map(ADDR_Global,RESET,enable_global1,decoder_out_global);-- the last one is the output it contains a vector that select the register of the window 
	
	decoder_GLOBAL_out1:DECODER_BEHAV_GENERIC
			generic map(log2(4*N)) 
			Port Map(ADD_RD1_GLObal,RESET,enable_global2,decoder_out1_global);
	
	decoder_GLOBAL_out2:DECODER_BEHAV_GENERIC
			generic map(log2(4*N)) 
			Port Map(ADD_RD2_GLObal,RESET,enable_global3,decoder_out2_global);
--------- the enable global is given by the most significant bit in the address--------------



	decoder_Current_Window_pointer:DECODER_BEHAV_GENERIC
			generic map(log2(4*N)) 
			Port Map(CWP,RESET,'1',tristate_enable);


----------- control unit for the behavior of the  Register file ---------

	controler:rf_control-- the part of the control
			generic  map(f=>f,
			n_bit=>n_bit)
	port map(	
		clk=>clk,
		call_signal=>call_signal,
		ret_signal=>ret_signal,
		reset=>reset,
		ack_mem=>ack_mem,
		spill_out=>spill_out_temp,
		fill_out=>fill_out_temp,
		canrestorein=>can_restore,
		cansavein=>can_save,
		canrestoreout=>can_restore,
		cansaveout=>can_save,
		cwp_out=>CWP,--this value is from 0 to 7 if we have 8 windows
		swp_out=>SWP);


spill_out<=spill_out_temp;
fill_out<=fill_out_temp;


----------------------- conection between the registers and the demux cables.This is done so that the in and the out is register are conected---------

	Reg_conect_wind:for i in 0 to F-1  generate 
		decoder_conect:for x in 0 to 3*N-1 generate-- conect the decoder
				enable_in(i*2*N+x)<=demux_in(i)(x);--notice that sometimes there are 2 cables conected to one cables this is solved using a Z state.
			end generate;
	end generate;
	
	Reg_conect_global:for i in 1 to 4*M generate 
		enable_in(NumReg-i)<=decoder_out_global(i-1);-- the globals are at the end of the register file
	end generate;
	


	Reg_conect_wind_out1:for i in 0 to F-1  generate 

		decoder_conect:for x in 0 to 3*N-1 generate
				enable_Out1(i*2*N+x)<=demux_out1(i)(x);
			end generate;
	end generate;
	
	Reg_conect_global_out1:for i in 1 to 4*M generate
		enable_out1(NumReg-i)<=decoder_out1_global(i-1);
	end generate;
	


	Reg_conect_wind_out2:for i in 0 to F-1  generate --create the register file compossed of an array of registers.

		decoder_conect:for x in 0 to 3*N-1 generate
				enable_Out2(i*2*N+x)<=demux_out2(i)(x);
			end generate;
	end generate;
	
	Reg_conect_global_out2:for i in 1 to 4*M generate --conection of the second decoder for the global registers
		enable_out2(NumReg-i)<=decoder_out2_global(i-1);
	end generate;


--------------NOW WE CONNECT THE TRI_STATE BUFFER THAT ALLOWS US TO HAVE TO CABLES CONECTECTED TO ONE REGISTER AND AVOID CONFLICT.-------------

	tri_state_connect:for i in 0 to F-1  generate
			tristate:tri_state_buffer
		   	Port Map(decoder_out_wind,tristate_enable(i),demux_in(i));---necesito otro decoder para el cwp que me active los trifasicos
	end generate;

    
Spill_and_Fill: process(spill_out_temp,fill_out_temp)
	begin
		if spill_out_temp='1' then-- in case of a spill we send all the register to the memorie
			for i in 0 to N*4-1 loop
				ADD_RD1_winded<=std_logic_vector(to_unsigned(i,ADDR_WINDED'length));
			end loop;
		end if;


		if fill_out_temp='1' then-- the same case of the spill but in this case the addres are for the write and not for the read
			for i in 0 to N*4-1 loop
				ADDR_WINDED<=std_logic_vector(to_unsigned(i,ADDR_WINDED'length));
			end loop;
		end if;
	end process;

end STRUCTURAL;






