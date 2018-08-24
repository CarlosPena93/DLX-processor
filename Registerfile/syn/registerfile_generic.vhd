library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.Numeric_Std.all;
use WORK.constants.all;

entity registerfile_generic is
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
end registerfile_generic;

architecture A of registerfile_generic is

        -- suggested structures
        subtype REG_ADDR is natural range 0 to n_bit-1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(data_bit-1 downto 0); 
	signal REGISTERS : REG_ARRAY;
	signal ADD_WR_INT : integer;
	signal ADD_RD1_INT: integer;
	signal ADD_RD2_INT: integer;

	
begin 
	regist: process(CLK,RESET,ENABLE)


	begin
		ADD_WR_INT <= to_integer(unsigned(ADD_WR));
		ADD_RD1_INT <= to_integer(unsigned(ADD_RD1));
		ADD_RD2_INT <= to_integer(unsigned(ADD_RD2));
		if CLK'event and CLK='1' then
			if RESET = '1' then 
				REGISTERS <= (others => (others => '0'));
			elsif ENABLE = '1' then
				if WR = '1' then
					REGISTERS(ADD_WR_INT) <= DATAIN;
				end if;
				if RD1 = '1' then
					OUT1 <= REGISTERS(ADD_RD1_INT);-- when CLK = '1';
				end if;
				if RD2 = '1' then
					OUT2 <= REGISTERS(ADD_RD2_INT);
				end if;
			end if;
		end if;
	end process;

end A;

----


configuration CFG_RF_BEH of registerfile_generic is
  for A
  end for;
end configuration;
