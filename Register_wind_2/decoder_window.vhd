library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use IEEE.Numeric_Std.all;
use WORK.constants.all; -- libreria WORK user-defined

entity DECODER_window is
	generic(N_bit:integer;
		N:integer);
	Port (	A:	In	std_logic_vector(N_bit-1 downto 0);--control signal
		rst:	In	std_logic;
		en:   	in 	std_logic;
		Y:	Out	std_logic_vector((3*N)-1 downto 0));--output of signals for adctivating the register
		
end DECODER_window; 


architecture  behav of DECODER_window is

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
       			for i in (3*N)-1 downto 0 loop
         				if (i = ainteger) then
           					y(i) <= '1';
         				else
           					y(i) <= '0';
         				end if;
       			end loop;
		     end if;
     		end if;
	end process;
end behav;




