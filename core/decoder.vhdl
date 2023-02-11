--! The base RISC-V ISA has fixed-length 32-bit instructions that must be naturally aligned on 32-bit boundaries.
--! However, the RISC-V encoding scheme is designed to support ISA extensions with variable-length instructions.
--! Where each instruction can be any number of 16-bit instruction parcels in length.
--! In this educational project we do not focus on implementing variable-length instructions.
--! Meaning, all we care about is 32-bit instructions only.
--!
--! In the base RV32I ISA, there are four core instruction formats (R/I/S/U).
--! R stands for register-register instructions, both operands and destination are registers.
--! I stands for register-immediate instructions, destination is a register but operand is an immediate value.
--! S stands for store instructions, where value from register writes into memory.
--! U stands for upper-immediate instructions, where value writes into the register.
--!
--! There are a further two variants of the instruction formats (B/J) based on the handling of immediate.
--! B stands for branching instructions, where the flow of the program changes based on condition.
--! J stands for jump instructions, where the flow of the program changes unconditionally.
--!
--! With the help of this entity we decode instructions into meaningful chunks of signals coming out from it.
--! We could do that in the control unit itself, but I decided to simplify it a bit.
--! So this is a simple combinational circuit that takes instruction as an input and outputs meaningful signals.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity decoder is
  port (
    instruction : in    std_logic_vector(31 downto 0);
    opcode      : out   std_logic_vector(6 downto 0);
    rd          : out   std_logic_vector(4 downto 0);
    rs1         : out   std_logic_vector(4 downto 0);
    rs2         : out   std_logic_vector(4 downto 0);
    funct3      : out   std_logic_vector(2 downto 0);
    funct7      : out   std_logic_vector(6 downto 0);
    immediate   : out   std_logic_vector(31 downto 0)
  );
end entity decoder;

architecture rtl of decoder is

  -- Vectors of instruction opcode combinations to distinguish instructions later in decoding
  -- They are named with the category of instructions to do and its encoding type
  constant alu_i_type : std_logic_vector(6 downto 0) := "0010011";
  constant alu_r_type : std_logic_vector(6 downto 0) := "0110011";

begin

  decode : process (instruction) is

    variable instruction_type : std_logic_vector(6 downto 0);

  begin

    -- I made an alias for 7 bits of instruction opcode to simplify decoding below
    instruction_type := instruction(6 downto 0);

    -- The actual decoding is happening here
    -- A great amount of if-s and then-s and I prefer to leave them isolated here, hopefully
    if (instruction_type = alu_i_type) then
      opcode <= instruction(6 downto 0);
      rd     <= instruction(11 downto 7);
      funct3 <= instruction(14 downto 12);
      rs1    <= instruction(19 downto 15);
      rs2    <= std_logic_vector(to_unsigned(0, rs2'length));

      if (instruction(14 downto 12) = "001" or instruction(14 downto 12) = "101") then
        immediate <= (31 downto 5 => '0') & instruction(24 downto 20);
        funct7    <= instruction(31 downto 25);
      else
        immediate <= (31 downto 12 => instruction(31)) & instruction(31 downto 20);
        funct7    <= (others => '0');
      end if;
    elsif (instruction_type = alu_r_type) then
      opcode <= instruction(6 downto 0);
      rd     <= instruction(11 downto 7);
      funct3 <= instruction(14 downto 12);
      rs1    <= instruction(19 downto 15);
      rs2    <= instruction(24 downto 20);
      funct7 <= instruction(31 downto 25);
    end if;

  end process decode;

end architecture rtl;
