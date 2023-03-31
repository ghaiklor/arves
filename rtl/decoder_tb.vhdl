--! There is a great tool I'm using to assemble the machine instruction online:
--! https://luplab.gitlab.io/rvcodecjs/
--!
--! With this tool, I'm assembling the binary that I'm feeding into instruction input.
--! Afterwards, running the simulation and checking if the outputs corresponds to what machine must do.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity decoder_tb is
end entity decoder_tb;

architecture tb of decoder_tb is

  component decoder is
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
  end component;

  signal instruction : std_logic_vector(31 downto 0);
  signal opcode      : std_logic_vector(6 downto 0);
  signal rd          : std_logic_vector(4 downto 0);
  signal rs1         : std_logic_vector(4 downto 0);
  signal rs2         : std_logic_vector(4 downto 0);
  signal funct3      : std_logic_vector(2 downto 0);
  signal funct7      : std_logic_vector(6 downto 0);
  signal immediate   : std_logic_vector(31 downto 0);

begin

  uut : component decoder
    port map (
      instruction => instruction,
      opcode      => opcode,
      rd          => rd,
      rs1         => rs1,
      rs2         => rs2,
      funct3      => funct3,
      funct7      => funct7,
      immediate   => immediate
    );

  stimuli : process is

    constant propagation_time : time := 1 ns;

  begin

    -- addi x3, x1, 127
    -- 00000111111100001000000110010011
    instruction <= "00000111111100001000000110010011";
    wait for propagation_time;

    assert opcode = "0010011"
      report "opcode must be ALU I-type"
      severity error;

    assert rd = std_logic_vector(to_unsigned(3, rd'length))
      report "rd must be 3"
      severity error;

    assert rs1 = std_logic_vector(to_unsigned(1, rd'length))
      report "rs1 must be 1"
      severity error;

    assert rs2 = std_logic_vector(to_unsigned(0, rd'length))
      report "rs2 must be 0"
      severity error;

    assert funct3 = "000"
      report "funct3 must be 000"
      severity error;

    assert funct7 = "0000000"
      report "funct7 must be 0000000"
      severity error;

    assert immediate = std_logic_vector(to_unsigned(127, immediate'length))
      report "immediate must be 127"
      severity error;

    -- ori x10, x7, 128
    -- 00001000000000111110010100010011
    instruction <= "00001000000000111110010100010011";
    wait for propagation_time;

    assert opcode = "0010011"
      report "opcode must be ALU I-type"
      severity error;

    assert rd = std_logic_vector(to_unsigned(10, rd'length))
      report "rd must be 10"
      severity error;

    assert rs1 = std_logic_vector(to_unsigned(7, rd'length))
      report "rs1 must be 7"
      severity error;

    assert rs2 = std_logic_vector(to_unsigned(0, rd'length))
      report "rs2 must be 0"
      severity error;

    assert funct3 = "110"
      report "funct3 must be 110"
      severity error;

    assert funct7 = "0000000"
      report "funct7 must be 0000000"
      severity error;

    assert immediate = std_logic_vector(to_unsigned(128, immediate'length))
      report "immediate must be 128"
      severity error;

    -- srai x4, x3, 8
    -- 01000000100000011101001000010011
    instruction <= "01000000100000011101001000010011";
    wait for propagation_time;

    assert opcode = "0010011"
      report "opcode must be ALU I-type"
      severity error;

    assert rd = std_logic_vector(to_unsigned(4, rd'length))
      report "rd must be 4"
      severity error;

    assert rs1 = std_logic_vector(to_unsigned(3, rd'length))
      report "rs1 must be 3"
      severity error;

    assert rs2 = std_logic_vector(to_unsigned(0, rd'length))
      report "rs2 must be 0"
      severity error;

    assert funct3 = "101"
      report "funct3 must be 101"
      severity error;

    assert funct7 = "0100000"
      report "funct7 must be 0100000"
      severity error;

    assert immediate = std_logic_vector(to_unsigned(8, immediate'length))
      report "immediate must be 8"
      severity error;

    -- sub x8, x9, x10
    -- 01000000101001001000010000110011
    instruction <= "01000000101001001000010000110011";
    wait for propagation_time;

    assert opcode = "0110011"
      report "opcode must be ALU R-type"
      severity error;

    assert rd = std_logic_vector(to_unsigned(8, rd'length))
      report "rd must be 8"
      severity error;

    assert rs1 = std_logic_vector(to_unsigned(9, rd'length))
      report "rs1 must be 9"
      severity error;

    assert rs2 = std_logic_vector(to_unsigned(10, rd'length))
      report "rs2 must be 10"
      severity error;

    assert funct3 = "000"
      report "funct3 must be 000"
      severity error;

    assert funct7 = "0100000"
      report "funct7 must be 0100000"
      severity error;

    assert immediate = std_logic_vector(to_unsigned(0, immediate'length))
      report "immediate must be 0"
      severity error;

    assert false
      report "test bench for decoder is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
