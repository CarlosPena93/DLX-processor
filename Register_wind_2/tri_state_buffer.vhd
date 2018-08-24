library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tri_state_buffer is
    Port ( 
	   IN6  : in  STD_LOGIC_VECTOR (5 downto 0);
           EN6  : in  STD_LOGIC;
           OUT6 : out STD_LOGIC_VECTOR (5 downto 0));
end tri_state_buffer;

architecture Behavioral of tri_state_buffer is

begin


     -- 4 input/output active low enabled tri-state buffer
    OUT6 <= IN6 when (EN6 = '1') else "ZZZZZZ"; -- 5 input/output active low enabled tri-state buffer
    OUT6 <= IN6 when (EN6 = '1') else "ZZZZZZ";
end Behavioral;
