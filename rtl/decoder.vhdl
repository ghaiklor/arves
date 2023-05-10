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

  -- Field "opcode" in RISC-V instruction specifies the type of operation to perform
  -- Here, I'm mapping the field to constants in order to simplify decoding
  -- Later on, we compare the "opcode" field from the instruction with these vectors
  constant jump_and_link_type          : std_logic_vector(6 downto 0) := "1101111";
  constant jump_and_link_register_type : std_logic_vector(6 downto 0) := "1100111";
  constant branching_type              : std_logic_vector(6 downto 0) := "1100011";
  constant load_type                   : std_logic_vector(6 downto 0) := "0000011";
  constant store_type                  : std_logic_vector(6 downto 0) := "0100011";
  constant alu_i_type                  : std_logic_vector(6 downto 0) := "0010011";
  constant alu_r_type                  : std_logic_vector(6 downto 0) := "0110011";

begin

  decode : process (instruction) is

    variable instruction_type : std_logic_vector(6 downto 0);

  begin

    -- Assigning "opcode" field to the instruction_type helps to map it on the opcode vectors above
    instruction_type := instruction(6 downto 0);

    -- The actual decoding of the instruction is happening here
    case instruction_type is

      when jump_and_link_type =>

        opcode    <= instruction(6 downto 0);
        rd        <= instruction(11 downto 7);
        rs1       <= std_logic_vector(to_unsigned(0, rs1'length));
        rs2       <= std_logic_vector(to_unsigned(0, rs2'length));
        funct3    <= (others => '0');
        funct7    <= (others => '0');
        immediate <= (31 downto 21 => instruction(31)) & instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0';

      when jump_and_link_register_type =>

        opcode    <= instruction(6 downto 0);
        rd        <= instruction(11 downto 7);
        rs1       <= instruction(19 downto 15);
        rs2       <= std_logic_vector(to_unsigned(0, rs2'length));
        funct3    <= instruction(14 downto 12);
        funct7    <= (others => '0');
        immediate <= (31 downto 12 => instruction(31)) & instruction(31 downto 20);

      when branching_type =>

        opcode    <= instruction(6 downto 0);
        rd        <= std_logic_vector(to_unsigned(0, rd'length));
        rs1       <= instruction(19 downto 15);
        rs2       <= instruction(24 downto 20);
        funct3    <= instruction(14 downto 12);
        funct7    <= (others => '0');
        immediate <= (31 downto 13 => instruction(31)) & instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';

      when load_type =>

        opcode    <= instruction(6 downto 0);
        rd        <= instruction(11 downto 7);
        rs1       <= instruction(19 downto 15);
        rs2       <= std_logic_vector(to_unsigned(0, rs2'length));
        funct3    <= instruction(14 downto 12);
        funct7    <= (others => '0');
        immediate <= (31 downto 12 => instruction(31)) & instruction(31 downto 20);

      when store_type =>

        opcode    <= instruction(6 downto 0);
        rd        <= std_logic_vector(to_unsigned(0, rd'length));
        rs1       <= instruction(19 downto 15);
        rs2       <= instruction(24 downto 20);
        funct3    <= instruction(14 downto 12);
        funct7    <= (others => '0');
        immediate <= (31 downto 12 => instruction(31)) & instruction(31 downto 25) & instruction(11 downto 7);

      when alu_i_type =>

        opcode <= instruction(6 downto 0);
        rd     <= instruction(11 downto 7);
        rs1    <= instruction(19 downto 15);
        rs2    <= std_logic_vector(to_unsigned(0, rs2'length));
        funct3 <= instruction(14 downto 12);

        -- Depending on funct3 vector, we need to treat funct7 and immediate fields differently
        case instruction(14 downto 12) is

          -- When it is a SLL, SRL or SRA operations, we need to take shift amount as immediate and funct7 fields
          when "101" | "001" =>

            funct7    <= instruction(31 downto 25);
            immediate <= (31 downto 5 => '0') & instruction(24 downto 20);

          -- In other cases, we treat the rest of the instruction as an immediate value
          when others =>

            funct7    <= (others => '0');
            immediate <= (31 downto 12 => instruction(31)) & instruction(31 downto 20);

        end case;

      when alu_r_type =>

        opcode    <= instruction(6 downto 0);
        rd        <= instruction(11 downto 7);
        rs1       <= instruction(19 downto 15);
        rs2       <= instruction(24 downto 20);
        funct3    <= instruction(14 downto 12);
        funct7    <= instruction(31 downto 25);
        immediate <= std_logic_vector(to_unsigned(0, immediate'length));

      when others =>

        null;

    end case;

  end process decode;

end architecture rtl;
