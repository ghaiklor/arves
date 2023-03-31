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
    opcode : in    std_logic_vector(6 downto 0);
    funct3 : in    std_logic_vector(2 downto 0);
    funct7 : in    std_logic_vector(6 downto 0);
    result : out   std_logic_vector(31 downto 0)
  );
end entity alu;

architecture rtl of alu is

  -- These vectors are concatenated vectors of funct7, funct3 and opcode fields from RISC-V specification
  -- They made to simplify internal decoding of computational instruction
  -- In other words, I could say, this is the direct mapping from RISC-V specification
  constant addition_i_type               : std_logic_vector(16 downto 0) := "0000000" & "000" & "0010011";
  constant set_less_than_signed_i_type   : std_logic_vector(16 downto 0) := "0000000" & "010" & "0010011";
  constant set_less_than_unsigned_i_type : std_logic_vector(16 downto 0) := "0000000" & "011" & "0010011";
  constant exclusive_or_i_type           : std_logic_vector(16 downto 0) := "0000000" & "100" & "0010011";
  constant logical_or_i_type             : std_logic_vector(16 downto 0) := "0000000" & "110" & "0010011";
  constant logical_and_i_type            : std_logic_vector(16 downto 0) := "0000000" & "111" & "0010011";
  constant shift_left_logical_i_type     : std_logic_vector(16 downto 0) := "0000000" & "001" & "0010011";
  constant shift_right_logical_i_type    : std_logic_vector(16 downto 0) := "0000000" & "101" & "0010011";
  constant shift_right_arithmetic_i_type : std_logic_vector(16 downto 0) := "0100000" & "101" & "0010011";
  constant addition_r_type               : std_logic_vector(16 downto 0) := "0000000" & "000" & "0110011";
  constant subtraction_r_type            : std_logic_vector(16 downto 0) := "0100000" & "000" & "0110011";
  constant shift_left_logical_r_type     : std_logic_vector(16 downto 0) := "0000000" & "001" & "0110011";
  constant set_less_than_signed_r_type   : std_logic_vector(16 downto 0) := "0000000" & "010" & "0110011";
  constant set_less_than_unsigned_r_type : std_logic_vector(16 downto 0) := "0000000" & "011" & "0110011";
  constant exclusive_or_r_type           : std_logic_vector(16 downto 0) := "0000000" & "100" & "0110011";
  constant shift_right_logical_r_type    : std_logic_vector(16 downto 0) := "0000000" & "101" & "0110011";
  constant shift_right_arithmetic_r_type : std_logic_vector(16 downto 0) := "0100000" & "101" & "0110011";
  constant logical_or_r_type             : std_logic_vector(16 downto 0) := "0000000" & "110" & "0110011";
  constant logical_and_r_type            : std_logic_vector(16 downto 0) := "0000000" & "111" & "0110011";

begin

  compute : process (a, b, opcode, funct3, funct7) is

    variable compute_type : std_logic_vector(16 downto 0);

  begin

    -- Concatenate funct7, funct3 and opcode fields in order to get a vector to compare with the compute types above
    compute_type := funct7 & funct3 & opcode;

    -- Depending on the compute type we choose what kind of operation to perform on A and B
    case compute_type is

      -- ADD performs the addition of signed a and b
      when addition_i_type | addition_r_type =>

        result <= std_logic_vector(signed(a) + signed(b));

      -- SUB performs the subtraction of signed a and b
      when subtraction_r_type =>

        result <= std_logic_vector(signed(a) - signed(b));

      -- SLL perform logical left on the value in a by the shift amount held in the lower 5 bits of b
      when shift_left_logical_i_type | shift_left_logical_r_type =>

        result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0)))));

      -- SLT perform signed compares, writing 1 to result if A < B, 0 otherwise
      when set_less_than_signed_i_type | set_less_than_signed_r_type =>

        if (signed(a) < signed(b)) then
          result <= std_logic_vector(to_unsigned(1, result'length));
        else
          result <= std_logic_vector(to_unsigned(0, result'length));
        end if;

      -- SLTU perform unsigned compares, writing 1 to result if A < B, 0 otherwise
      when set_less_than_unsigned_i_type | set_less_than_unsigned_r_type =>

        if (unsigned(a) < unsigned(b)) then
          result <= std_logic_vector(to_unsigned(1, result'length));
        else
          result <= std_logic_vector(to_unsigned(0, result'length));
        end if;

      -- XOR perform bitwise exclusive OR
      when exclusive_or_i_type | exclusive_or_r_type =>

        result <= a xor b;

      -- SRL perform logical right on the value in a by the shift amount held in the lower 5 bits of b
      when shift_right_logical_i_type | shift_right_logical_r_type =>

        result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));

      -- SRA perform arithmetic right shift on the value in a by the shift amount held in the lower 5 bits of b
      when shift_right_arithmetic_i_type | shift_right_arithmetic_r_type =>

        result <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));

      -- OR perform bitwise logical OR
      when logical_or_i_type | logical_or_r_type =>

        result <= a or b;

      -- AND perform bitwise logical AND
      when logical_and_i_type | logical_and_r_type =>

        result <= a and b;

      -- Shouldn't really happen, but if it is then I prefer to have a constant zero there
      when others =>

        result <= std_logic_vector(to_unsigned(0, result'length));

    end case;

  end process compute;

end architecture rtl;
