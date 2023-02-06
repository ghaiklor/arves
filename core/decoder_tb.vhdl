--! While decoding machine instructions, it can become too cumbersome to check all the outputs of the entity.
--! So that, this test bench has no assertions at all.
--! All I'm doing here is just setting some instructions at the input and checking the output manually in wave viewer.
--!
--! There is a great tool I'm using to assemble the machine instruction online:
--! https://luplab.gitlab.io/rvcodecjs/
--!
--! With this tool, I'm assembling the binary that I'm feeding into instruction input.
--! Afterwards, running the simulation and checking if the outputs corresponds to what machine must do.
--!
--! The reason I'm not doing assertions here is that I hope to integrate some of the compliance tests later.
--! Some of them are the tests that operate on instruction-level, meaning, they will check exactly what I need.

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

    -- ori x10, x7, 128
    -- 00001000000000111110010100010011
    instruction <= "00001000000000111110010100010011";
    wait for propagation_time;

    -- srai x4, x3, 8
    -- 01000000100000011101001000010011
    instruction <= "01000000100000011101001000010011";
    wait for propagation_time;

    -- sub x8, x9, x10
    -- 01000000101001001000010000110011
    instruction <= "01000000101001001000010000110011";
    wait for propagation_time;

    assert false
      report "test bench for decoder is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
