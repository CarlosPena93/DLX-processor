
library IEEE;

use IEEE.std_logic_1164.all;

package 
   CONV_PACK_CU_DLX_MP2_MEM_SIZE19_CONTROL_w11_FUNC_SIZE11_OP_CODE_SIZE6_ALU_OPC_SIZE2_IR_SIZE32_MICROCODE_MEM_SIZE32_INSTRUCTIONS_EXECUTION_CYCLES3_RELOC_MEM_SIZE16 
   is

-- define attributes
attribute ENUM_ENCODING : STRING;

end 
   CONV_PACK_CU_DLX_MP2_MEM_SIZE19_CONTROL_w11_FUNC_SIZE11_OP_CODE_SIZE6_ALU_OPC_SIZE2_IR_SIZE32_MICROCODE_MEM_SIZE32_INSTRUCTIONS_EXECUTION_CYCLES3_RELOC_MEM_SIZE16;

library IEEE;

use IEEE.std_logic_1164.all;

use 
   work.CONV_PACK_CU_DLX_MP2_MEM_SIZE19_CONTROL_w11_FUNC_SIZE11_OP_CODE_SIZE6_ALU_OPC_SIZE2_IR_SIZE32_MICROCODE_MEM_SIZE32_INSTRUCTIONS_EXECUTION_CYCLES3_RELOC_MEM_SIZE16.all;

entity 
   CU_DLX_MP2_MEM_SIZE19_CONTROL_w11_FUNC_SIZE11_OP_CODE_SIZE6_ALU_OPC_SIZE2_IR_SIZE32_MICROCODE_MEM_SIZE32_INSTRUCTIONS_EXECUTION_CYCLES3_RELOC_MEM_SIZE16 
   is

   port( EN1, RF1, RF2, WF1, EN2, S1, S2 : out std_logic;  ALU_OPCODE : out 
         std_logic_vector (1 downto 0);  EN3, RM, WM, S3 : out std_logic;  
         OPCODE : in std_logic_vector (5 downto 0);  FUNC : in std_logic_vector
         (10 downto 0);  Clk, Rst : in std_logic);

end 
   CU_DLX_MP2_MEM_SIZE19_CONTROL_w11_FUNC_SIZE11_OP_CODE_SIZE6_ALU_OPC_SIZE2_IR_SIZE32_MICROCODE_MEM_SIZE32_INSTRUCTIONS_EXECUTION_CYCLES3_RELOC_MEM_SIZE16;

architecture SYN_dlx_cu_rtl of 
   CU_DLX_MP2_MEM_SIZE19_CONTROL_w11_FUNC_SIZE11_OP_CODE_SIZE6_ALU_OPC_SIZE2_IR_SIZE32_MICROCODE_MEM_SIZE32_INSTRUCTIONS_EXECUTION_CYCLES3_RELOC_MEM_SIZE16 
   is

   component NOR2_X1
      port( A1, A2 : in std_logic;  ZN : out std_logic);
   end component;
   
   component NOR3_X1
      port( A1, A2, A3 : in std_logic;  ZN : out std_logic);
   end component;
   
   component NOR4_X1
      port( A1, A2, A3, A4 : in std_logic;  ZN : out std_logic);
   end component;
   
   component AND3_X1
      port( A1, A2, A3 : in std_logic;  ZN : out std_logic);
   end component;
   
   component AOI211_X1
      port( C1, C2, A, B : in std_logic;  ZN : out std_logic);
   end component;
   
   component OR2_X1
      port( A1, A2 : in std_logic;  ZN : out std_logic);
   end component;
   
   component MUX2_X1
      port( A, B, S : in std_logic;  Z : out std_logic);
   end component;
   
   component AOI21_X1
      port( B1, B2, A : in std_logic;  ZN : out std_logic);
   end component;
   
   component INV_X1
      port( A : in std_logic;  ZN : out std_logic);
   end component;
   
   signal n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34 
      : std_logic;

begin
   
   U20 : NOR3_X1 port map( A1 => OPCODE(4), A2 => OPCODE(5), A3 => n21, ZN => 
                           ALU_OPCODE(1));
   U21 : INV_X1 port map( A => n22, ZN => n21);
   U22 : MUX2_X1 port map( A => n23, B => n24, S => OPCODE(1), Z => n22);
   U23 : NOR2_X1 port map( A1 => OPCODE(3), A2 => n25, ZN => n24);
   U24 : INV_X1 port map( A => OPCODE(0), ZN => n25);
   U25 : NOR2_X1 port map( A1 => OPCODE(0), A2 => n26, ZN => n23);
   U26 : MUX2_X1 port map( A => n27, B => OPCODE(2), S => OPCODE(3), Z => n26);
   U27 : AOI21_X1 port map( B1 => FUNC(1), B2 => n28, A => OPCODE(2), ZN => n27
                           );
   U28 : NOR4_X1 port map( A1 => OPCODE(5), A2 => OPCODE(4), A3 => OPCODE(0), 
                           A4 => n29, ZN => ALU_OPCODE(0));
   U29 : MUX2_X1 port map( A => n30, B => n31, S => OPCODE(3), Z => n29);
   U30 : OR2_X1 port map( A1 => OPCODE(1), A2 => OPCODE(2), ZN => n31);
   U31 : AOI211_X1 port map( C1 => FUNC(0), C2 => n28, A => OPCODE(2), B => 
                           OPCODE(1), ZN => n30);
   U32 : AND3_X1 port map( A1 => n32, A2 => n33, A3 => n34, ZN => n28);
   U33 : NOR4_X1 port map( A1 => FUNC(4), A2 => FUNC(3), A3 => FUNC(2), A4 => 
                           FUNC(10), ZN => n34);
   U34 : NOR3_X1 port map( A1 => FUNC(7), A2 => FUNC(9), A3 => FUNC(8), ZN => 
                           n33);
   U35 : NOR2_X1 port map( A1 => FUNC(6), A2 => FUNC(5), ZN => n32);

end SYN_dlx_cu_rtl;
