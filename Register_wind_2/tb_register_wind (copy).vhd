library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;
use WORK.constants.all;

entity tb_register_wind_2 is 

end tb_register_wind_2; 

architecture test_register_wind_2 of tb_register_wind_2 is

signal Din:		std_logic_vector(N_BIT-1 downto 0);
signal ADDR:		std_logic_vector(2*log2(N*4) downto 0);-- the address of the window decoder and global decoder are in this addr.there are some forbiden adresses.
signal call_signal: 	std_logic;
signal ret_signal: 	std_logic;
signal ack_mem:		std_logic;
signal CLK:		std_logic:='0';
signal ADD_RD1: 	std_logic_vector(2*log2(N*4)  downto 0);--5 downto 0
signal ADD_RD2: 	std_logic_vector(2*log2(N*4)  downto 0);--5 downto 0
signal RESET:		std_logic;
signal Dout1:		std_logic_vector(N_BIT-1 downto 0);
signal Dout2:		std_logic_vector(N_BIT-1 downto 0);
signal MUX_OUT:		std_logic_vector(N_BIT-1 downto 0);
signal spill_out:	std_logic;
signal fill_out:	std_logic;
signal start_call:	std_logic;
signal start_ret:	std_logic;
signal counter: 	integer := 0;

component REGISTER_Wind_2 
	GENERIC(N_BIT:integer;--number of bits per register
		NumReg:integer;--number of registers
		N:integer;-- N is for lo
		M:integer;
		F:integer); --number of windows
	Port (	Din:	In	std_logic_vector(N_BIT-1 downto 0);
		ADDR:   In	std_logic_vector(2*log2(N*4)-1 downto 0);-- the address of the window decoder and global decoder are in this addr.there are some forbiden adresses.
		call_signal:  in std_logic;
		ret_signal: 	in std_logic;
		ack_mem:	in std_logic;
		CLK:		In std_logic;
		ADD_RD1: 	IN std_logic_vector(2*log2(N*4)-1  downto 0);--5 downto 0
		ADD_RD2: 	IN std_logic_vector(2*log2(N*4)-1  downto 0);--5 downto 0
		RESET:	In	std_logic;
		Dout1:Out	std_logic_vector(N_BIT-1 downto 0);
		Dout2:Out	std_logic_vector(N_BIT-1 downto 0);
		MUX_OUT:Out	std_logic_vector(N_BIT-1 downto 0);
		spill_out:     out std_logic;
		fill_out:	out std_logic
	
	);
end component;


begin
	
reset <= '1','0' after 0.7 ns;

PCLOCK : process(CLK)
	begin
		CLK <= not(CLK) after 0.5 ns;	
	end process;

callers:process(clk,start_call)
begin
	
	if start_call='1' then
		if clk'event and clk = '1' then
			call_signal<= not (call_signal) after 0.25 ns;
		end if;
	else 	
		call_signal<= '0';
	end if;
end process;

dining:process(call_signal)
begin

	if call_signal = '1' then
		Din <= std_logic_vector(to_unsigned(counter, Din'length));
		counter <= counter + 1;	
	end if; 
end process;

	start_call <= '0', '1' after 1 ns,'0' after 48 ns;

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

memory_ack: process(spill_out, fill_out)
	begin
		if ((spill_out = '1') or (fill_out = '1')) then
			ack_mem <= '0','1' after 0.2 ns,'0'after 1.2 ns ;
		end if;
	end process;

ADDR <= "0000000", "0000100" after 5 ns, "1000010" after 10 ns, "1010011" after 15 ns;

ADD_RD1 <= "0000000", "0001000" after 51 ns, "0010010" after 57 ns, "1010011" after 64 ns;
ADD_RD2 <= "0000000", "0000100" after 51 ns, "1000010" after 57 ns, "1010011" after 64 ns;


registercomplete:register_wind_2
	generic map (n_bit,numreg,n,m,f)
port map(Din,ADDR,call_signal,ret_signal,ack_mem,clk,add_rd1,add_rd2,reset,Dout1,Dout2,mux_out,spill_out,fill_out);

	--reset <= '1','0' after 2 ns;
	--en <= '0','1' after 1 ns;	
	--RD1 <= '1','0' after 5 ns, '1' after 13 ns, '0' after 20 ns; 


end test_register_wind_2;
