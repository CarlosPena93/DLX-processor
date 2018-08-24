library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.Numeric_Std.all;
use WORK.constants.all;

entity instruction_mem is
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
end instruction_mem;

architecture behavioral of memory_generic is

        -- suggested structures
subtype REG_ADDR is natural range 0 to n_bit**2-1; -- using natural type
type REG_ARRAY is array(REG_ADDR) of std_logic_vector(data_bit-1 downto 0); 
signal REGISTERS : REG_ARRAY;
signal ADD_WR_INT : integer;
signal ADD_RD1_INT: integer;

type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CONTROL_w - 1 downto 0);--the memorie type that has the diferent instructions

signal microcode : mem_array := (X"8F27", -- 0000: load.l  r7 0x27 # Top of the stack
                                X"8307", -- 0001: load.l  r1 7 # constant argument 1
                                X"8503", -- 0002: load.l  r2 3 # constant argument 2
                                X"1EE7", -- 0003: subi    r7 r7 3 # reserve 3 words of stack
                                X"70E6", -- 0004: write   r7 r1 2 # write argument at offset +2
                                X"70E9", -- 0005: write   r7 r2 1 # write argument at offset +1
                                X"EC00", -- 0006: spc     r6 # get current pc
                                X"0CC9", -- 0007: addi    r6 r6 4 # offset to after the call
                                X"70F8", -- 0008: write   r7 r6 # put return PC on stack
                                X"C10C", -- 0009: bi      0x000c # call
                                X"0EE7", -- 000A: addi    r7 r7 3 # pop stack
                                X"C117", -- 000B: bi      0x0017
                                X"62E2", -- 000C: read    r1 r7 2
                                X"64E1", -- 000D: read    r2 r7 1
                                X"8100", -- 000E: load.l  r0 0
                                X"9A48", -- 000F: cmp.u   r5 r2 r2
                                X"D3A4", -- 0010: bro.az  r5 4
                                X"0004", -- 0011: add     r0 r0 r1
                                X"1443", -- 0012: subi.u  r2 r2 1
                                X"C10F", -- 0013: bi      0x000f
                                X"6CE0", -- 0014: read    r6 r7 0
                                X"C0C0", -- 0015: br      r6
                                X"C116", -- 0016: bi      0x0016
                                X"2000", -- 0017: or      r0 r0 r0
                                X"C117", -- 0018: bi      0x0017
                                );


begin 
	regist: process(RESET,ENABLE)

	begin
		ADD_WR_INT <= to_integer(unsigned(ADD_WR));
		ADD_RD1_INT <= to_integer(unsigned(ADD_RD1));
		
		if RESET = '1' then 
			REGISTERS <= (others => (others => '0'));
		elsif ENABLE = '1' then
			if WR = '1' then
				REGISTERS(ADD_WR_INT) <= DATAIN;
			end if;
			if RD = '1' then
				OUT1 <= REGISTERS(ADD_RD1_INT);
			end if;	
		end if;
	end process;
end behavioral;
