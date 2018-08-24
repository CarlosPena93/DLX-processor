library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.Numeric_Std.all;
use ieee.std_logic_signed.all;
use WORK.constants.all;

entity rf_control is 
	generic(f:integer;--Number of windows
		n_bit:integer--numer of bits per register
		);
	port(	
		clk:		in std_logic;
		call_signal,ret_signal: 		in std_logic;
		reset:		in std_logic;
		ack_mem:	in std_logic;
		spill_out,fill_out:	out std_logic;
		canrestorein:	in std_logic_vector(n_bit-1 downto 0);
		cansavein:	in std_logic_vector(n_bit-1 downto 0);
		canrestoreout:	out std_logic_vector(n_bit-1 downto 0);
		cansaveout:	out std_logic_vector(n_bit-1 downto 0);
		cwp_out:	out std_logic_vector(log2(f)-1 downto 0);--valor del log2(f)
		swp_out:out std_logic_vector(log2(f)-1 downto 0));--log2(f)


end rf_control;

--function increase(
--	X: in std_logic_vector)
--	return std_logic_vector is
--begin 
--	if X /= (X'range => '1') then
--		X <= X + '1';
--	else 
--		X <= (others => '0');
--	end if ;
--	return X;
--end increase;

architecture r of rf_control is

signal cwp_pass: std_logic_vector(log2(f)-1 downto 0) := (others => '1');--valor del log2
--gnal window_end: std_logic_vector(loga-1 downto 0);--to know when the max number of the windows is reached (log2(f))
type statetype is (call, rst, available, ret, spill,fill);
signal current_state : statetype;

begin 
	
	--window_end <= (loga-1 downto 0 => '1');--all bits in 1 = maximum number of windows (log2(f))
	reg_control:process(clk,reset)
	begin	
		if clk'event and clk = '1' then
			if reset = '1' then
				current_state <= rst;
			else
				case current_state is 
					when rst =>
						cwp_pass <= (others => '1');
						swp_out <= (others => '0');
						cansaveout <= std_logic_vector(to_unsigned(f-1,cansaveout'length));
						canrestoreout <= (others => '0');
						current_state <= available;

					when available =>
						if call_signal = '1' then
							if cansavein /=0 then
								cansaveout<=cansavein-1;
							end if;

							if canrestorein < (f-1) then
								canrestoreout<=canrestorein+1;
							end if;

							cwp_pass <= cwp_pass + '1';
							

							current_state <= call;
						elsif ret_signal = '1' then
							if cansavein /=(f-1) then
								cansaveout<=cansavein+1;
							end if;
							if canrestorein /=0 then 
								canrestoreout<=canrestorein-1;
							end if;
							cwp_pass <= cwp_pass - '1';
							current_state <= ret;
						end if;

					when call =>		
						if cansavein = (cansavein'range => '0') then
							current_state <= spill;	
						else 	
							current_state <= available;
						end if;						
					when ret =>
						if canrestorein = (canrestorein'range => '0') then
							current_state <= fill;			
						else
						
							current_state <= available;
					
						end if;	

					when spill =>
						swp_out <= cwp_pass+2;
						--RECORDAR SUMAR EL CWP ANTES DE HCER EL  SPILL!!!
						spill_out<='1';
						if (ack_mem='1') then 
							spill_out<='0';
							cansaveout<=cansavein+1;
							canrestoreout<=canrestorein-1;
							current_state<=available;
						else 
							current_state<=spill;
						end if;

					when fill =>
						fill_out<='1';
						if (ack_mem='1') then 
							current_state<=available;
							fill_out<='0';
						else 
							current_state<=fill;
						end if;

				end case;
						
			end if;		
		end if;
	end process;
	cwp_out <= cwp_pass;
end r;
