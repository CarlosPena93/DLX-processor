library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;
use IEEE.std_logic_signed.all;
use WORK.constants.all;

entity tb_rf_control is 
	generic(f:integer := 8;--Number of windows
		n_bit:integer := 3--numer of bits per register
		);
end tb_rf_control;

architecture test_rf_control of tb_rf_control is

signal	clk:		std_logic:= '0';
signal	call_signal:   	std_logic:='0';
signal 	start_call:	std_logic;
signal	start_ret:	std_logic;
signal	ret_signal: 	std_logic;
signal	reset:		std_logic;
signal 	ack_mem:	std_logic;
signal	spill_out: 	std_logic;
signal	fill_out:	std_logic;
signal 	canrestore:	std_logic_vector(n_bit-1 downto 0);
signal 	cansave:	std_logic_vector(n_bit-1 downto 0);
signal	cwp_out:	std_logic_vector(log2(f)-1 downto 0);--valor del log2(f)
signal	swp_out:	std_logic_vector(log2(f)-1 downto 0);--log2(f)

component rf_control 
	generic(f:integer;--Number of windows
		n_bit:integer--numer of bits per register
		);
	port(	
		clk:		in std_logic;
		call_signal,ret_signal: 	in std_logic;
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

begin

PCLOCK : process(CLK)
	begin
		CLK <= not(CLK) after 0.5 ns;	
	end process;

unitcontrol:rf_control
	generic map (f,n_bit)
	port map (clk,call_signal,ret_signal,reset,ack_mem,spill_out,fill_out,canrestore,cansave,canrestore,cansave,cwp_out,swp_out); 

	reset <= '1','0' after 0.7 ns;

callers:process(clk,start_call)

begin
	if start_call='1' then
		if clk'event and clk = '0' then
			call_signal<= not (call_signal) after 0.3 ns;
		end if;
	else 
		call_signal<= '0';
	end if;
end process;

	start_call <= '0', '1' after 1 ns,'0' after 48 ns, '1' after 99 ns, '0' after 102 ns;

returners:process(clk,start_ret)
begin
	if start_ret = '1' then
		if clk'event and clk = '0' then
			ret_signal <= not(ret_signal) after 0.3 ns;
		end if;
	else
		ret_signal <= '0';
	end if;
end process;
	
	start_ret <= '0', '1' after 52 ns,'0' after 98 ns;

	--call_signal <= '0', '1' after 3 ns, '0' after 4 ns, '1' after 5 ns, '0' after 6 ns, '1' after 7 ns, '0' after 8 ns, '1' after 9 ns, '0' after 10 ns, '1' after 11 ns, '0' after 12 ns, '1' after 13 ns, '0' after 14 ns, '1' after 15 ns, '0' after 16 ns, '1' after 17 ns, '0' after 18 ns, '1' after 19 ns, '0' after 20 ns,'1' after 21 ns, '0' after 22 ns,'1' after 23 ns, '0' after 24 ns;
	--ret_signal <= '0', '1' after 27 ns, '0' after 28 ns;--, '1' after 28 ns, '0' after 29 ns, '1' after 30 ns, '0' after 31 ns, '1' after 32 ns, '0' after 33 ns, '1' after 34 ns, '0' after 35 ns;

memory_ack: process(spill_out, fill_out)
	begin
		if ((spill_out = '1') or (fill_out = '1')) then
			ack_mem <= '0','1' after 0.2 ns,'0'after 1.2 ns ;
		end if;
	end process;

end test_rf_control;
