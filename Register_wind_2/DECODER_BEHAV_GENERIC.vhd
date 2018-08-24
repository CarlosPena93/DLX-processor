library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use IEEE.Numeric_Std.all;
use WORK.constants.all; -- libreria WORK user-defined

entity DECODER_BEHAV_GENERIC is
	generic(N_bit:integer);
	Port (	A:	In	std_logic_vector(N_bit-1 downto 0);
		rst:	In	std_logic;
		en:   	in 	std_logic;
		Y:	Out	std_logic_vector(2**N_BIT-1 downto 0));
		
end DECODER_BEHAV_GENERIC; 


architecture  behav of DECODER_BEHAV_GENERIC is

signal ainteger:integer;
signal i :integer;

begin
decoder:process(rst,A)
	begin
	ainteger <= to_integer(unsigned(A));	 
		if ( rst = '1') then
       			y <= (others=>'0');
     		else
		     if (en = '1') then
       			for i in (2**N_bit)-1 downto 0 loop
         				if (i = ainteger) then
           					y(i) <= '1';
         				else
           					y(i) <= '0';
         				end if;
       			end loop;
		     else
			y <= (others=>'0');
		     end if;
     		end if;
	end process;
end behav;




