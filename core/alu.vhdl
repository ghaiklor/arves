--! Most integer computational instructions operate on 32/64 bits of values held in the integer register file.
--! Integer computational instructions are either encoded as register-immediate instruction or as register-register.
--! The destination is register rd for both register-immediate and register-register instructions.
--!
--! However, we can hide the distinction in register-register and register-immediate instructions from ALU.
--! Since ALU must operate on 32/64 bits of values, it is not necessary for ALU to know about registers at all.
--! So that, it makes sense, to make the ALU understand only immediate values.
--! The control unit will be responsible for handling the register-register and register-immediate instructions.
--! Hence, it will read the values from registers and pass it to the ALU through the data bus.
--!
--! We can say the same about the result of operation.
--! ALU can know nothing about registers and writing to them.
--! Instead, it will pass the result of operation on the data bus as 32/64 bits of values.
--! The control unit will read the value from the data bus and pass it to the appropriate register for writing.
--!
--! What's left is to decide the type of operation to execute.
--! According to RISC-V specification, it is encoded as funct3 and funct7 fields in the machine instruction.
--! To simplify the decoding, I'm not making up some new opcodes here and just take those vectors as in.
--!
--! Let's make a summary now.
--! We have two operands A and B which are 32/64 bits long (depending on the architecture).
--! To specify what kind of operation we need to perform on A and B, we have funct3 and funct7 vectors.
--! These are vectors that passed as is to the ALU by the control unit.
--! Result of operation is passed on the data bus which is 32/64 bits long.
--! So that, we can write the pseudo-code that implements it:
--! result = A funct3/7 B.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity alu is
  port (
    a      : in    std_logic_vector(31 downto 0);
    b      : in    std_logic_vector(31 downto 0);
    funct3 : in    std_logic_vector(2 downto 0);
    funct7 : in    std_logic_vector(6 downto 0);
    result : out   std_logic_vector(31 downto 0)
  );
end entity alu;

architecture rtl of alu is

  -- These vectors are concatenated vectors of funct7 and funct3 fields from RISC-V specification
  -- They made to simplify internal decoding of operation code
  constant addition               : std_logic_vector := "0000000" & "000";
  constant subtraction            : std_logic_vector := "0100000" & "000";
  constant shift_left_logical     : std_logic_vector := "0000000" & "001";
  constant set_less_than_signed   : std_logic_vector := "0000000" & "010";
  constant set_less_than_unsigned : std_logic_vector := "0000000" & "011";
  constant exclusive_or           : std_logic_vector := "0000000" & "100";
  constant shift_right_logical    : std_logic_vector := "0000000" & "101";
  constant shift_right_arithmetic : std_logic_vector := "0100000" & "101";
  constant logical_or             : std_logic_vector := "0000000" & "110";
  constant logical_and            : std_logic_vector := "0000000" & "111";

begin

  execute : process (a, b, funct3, funct7) is

    variable opcode : std_logic_vector(9 downto 0);

  begin

    -- Concatenate signals from funct7 and funct3 inputs in one vector to decode the operation
    -- This opcode is compared with the constant vectors above
    opcode := funct7 & funct3;

    -- Here we make the actual comparing of internal opcode vector with the constant vectors
    -- For any computational instruction from RISC-V specification there is a code to implement it in hardware
    if (opcode = addition) then
      result <= std_logic_vector(signed(a) + signed(b));
    elsif (opcode = subtraction) then
      result <= std_logic_vector(signed(a) - signed(b));
    elsif (opcode = shift_left_logical) then
      result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
    elsif (opcode = set_less_than_signed) then
      if (signed(a) < signed(b)) then
        result <= std_logic_vector(to_unsigned(1, result'length));
      else
        result <= std_logic_vector(to_unsigned(0, result'length));
      end if;
    elsif (opcode = set_less_than_unsigned) then
      if (unsigned(a) < unsigned(b)) then
        result <= std_logic_vector(to_unsigned(1, result'length));
      else
        result <= std_logic_vector(to_unsigned(0, result'length));
      end if;
    elsif (opcode = exclusive_or) then
      result <= a xor b;
    elsif (opcode = shift_right_logical) then
      result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
    elsif (opcode = shift_right_arithmetic) then
      result <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));
    elsif (opcode = logical_or) then
      result <= a or b;
    elsif (opcode = logical_and) then
      result <= a and b;
    else
      result <= std_logic_vector(to_unsigned(0, result'length));
    end if;

  end process execute;

end architecture rtl;
