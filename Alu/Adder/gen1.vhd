library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all;

entity GEN1 is 
	generic(N_bit:integer);
	port(
		A: in std_logic_vector(N_bit-1 downto 0);
		B: in std_logic_vector(N_bit-1 downto 0);
		Cin: in std_logic;
		Gout: out std_logic);
end GEN1;

architecture structural of GEN1 is 


signal Gen_Signal:std_logic_vector(N_bit-1 downto 0); -- array containing the results of the generate of two value (and)
signal Prop_Signal,propint:std_logic_vector(N_bit-1 downto 0);-- array containing the propagates needed of the Generates
signal Interm_SignalVector:std_logic_vector(N_bit-1 downto 0);-- array containing the ands of the gen_signal and Prop_signal
signal Interm_Signal:std_logic_vector(N_bit-1 downto 0);-- array containing the cascade of ors for the final value


	begin
	--we want to do the following  G4:1=g4+p4*g3+p4*p3*g2+p4*p3*p2*g1
        
        Propint(N_bit-1)<='1'; --the first and must depend on g4
	Interm_signal(0)<=Interm_signalVector(0);

	cablesgen: for I in 0 to N_bit-1 generate
		Gen_Signal(I)<=A(I)and B(I);
	end generate;

	firstprops: for I in 0 to N_bit-2 generate -- calculate the propagathe from P4 to P2
		Prop_Signal(I)<=A(I+1)xor B(I+1);
	end generate;

	firstpropsintern: for I in N_bit-2 downto 0 generate -- make an and with the propagates first and acumulate just like with the propagate entity 
		propint(I)<=Prop_Signal(I) and propint(I+1);
	end generate;
 

	Ands:for I in 0 to N_bit-1 generate --calculates G3:1=p3p2g1   G2:1=g2+p2g1
		Interm_signalVector(I)<=Gen_Signal(I) and propint(I);
	end generate;
	
	Ors:for I in 1 to N_bit-1 generate --calculates the final value G4:1=g4 or g3 or g2 or g1
		Interm_signal(I)<=Interm_signalVector(I) or Interm_signal(I-1);  --acumulates
	end generate;	 

	Gout<=Interm_signal(N_bit-1)or (prop_signal(N_bit-2) and prop_signal(N_bit-3) and prop_signal(N_bit-4) and (A(0) xor B(0)) and cin);-- the value is the last value calculated on the singal Interm_signal
			    

end structural;
