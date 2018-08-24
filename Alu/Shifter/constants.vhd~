library ieee;

package CONSTANTS is
	function log2( arg : integer) return integer;
	constant N_bit: integer :=32;
	constant Numbit: integer := 8;
	constant f: integer := 8;
	constant m:	integer := 2;
	constant n:	integer := 2;
	constant numreg: integer := 64;
end CONSTANTS;

package body CONSTANTS is

  function log2 ( arg: integer )  return integer is
    variable temp    : integer := arg;
    variable result : integer := 0;
  begin
    while temp > 1 loop
      result := result + 1;
      temp    := temp / 2;
    end loop;
    return result;
  end function log2 ;

end CONSTANTS;
