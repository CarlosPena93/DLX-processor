library ieee;

package CONSTANTS is
	function log2( arg : integer) return integer;
   constant n_bit: integer := 32;-- the size of the data in each memory 
   constant data_bit: integer := 32;-- the number of memory slots
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
