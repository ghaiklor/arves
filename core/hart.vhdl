--! In my humble opinion, there is some inconsistency between different terms like "core", "microprocessor", etc.
--! And I'm not the only one who thinks the same way, according to different sources and references.
--! So that it makes sense to explain a bit what I mean by "hart" here.
--!
--! Talking from RISC-V perspective, "hart" means "hardware thread".
--! So, it is "something" that is able to fetch and execute instructions and have its own state (e.g. registers).
--! Here, in our implementation, hart is a component that combines all other components, like "umbrella" component.
--!
--! We already have components like ALU, Register File and Decoder and there will be more of them.
--! So anything new later on will be somehow connected here through the signals, like we did with those three of them.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity hart is
  port (
    instruction : in    std_logic_vector(31 downto 0);
    clk         : in    std_logic;
    reset       : in    std_logic
  );
end entity hart;

architecture rtl of hart is

  component alu is
    port (
      a      : in    std_logic_vector(31 downto 0);
      b      : in    std_logic_vector(31 downto 0);
      funct3 : in    std_logic_vector(2 downto 0);
      funct7 : in    std_logic_vector(6 downto 0);
      result : out   std_logic_vector(31 downto 0)
    );
  end component;

  component register_file is
    port (
      register_a_select     : in    std_logic_vector(4 downto 0);
      register_b_select     : in    std_logic_vector(4 downto 0);
      register_write_select : in    std_logic_vector(4 downto 0);
      data                  : in    std_logic_vector(31 downto 0);
      write_enable          : in    std_logic;
      clk                   : in    std_logic;
      reset                 : in    std_logic;
      out_a                 : out   std_logic_vector(31 downto 0);
      out_b                 : out   std_logic_vector(31 downto 0)
    );
  end component;

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

  -- ALU Signals
  signal alu_in_a       : std_logic_vector(31 downto 0);
  signal alu_in_b       : std_logic_vector(31 downto 0);
  signal alu_in_funct3  : std_logic_vector(2 downto 0);
  signal alu_in_funct7  : std_logic_vector(6 downto 0);
  signal alu_out_result : std_logic_vector(31 downto 0);

  -- Register File Signals
  signal register_file_in_a_select     : std_logic_vector(4 downto 0);
  signal register_file_in_b_select     : std_logic_vector(4 downto 0);
  signal register_file_in_write_select : std_logic_vector(4 downto 0);
  signal register_file_in_data         : std_logic_vector(31 downto 0);
  signal register_file_in_write_enable : std_logic;
  signal register_file_in_clk          : std_logic;
  signal register_file_in_reset        : std_logic;
  signal register_file_out_a           : std_logic_vector(31 downto 0);
  signal register_file_out_b           : std_logic_vector(31 downto 0);

  -- Decoder Signals
  signal decoder_in_instruction : std_logic_vector(31 downto 0);
  signal decoder_out_opcode     : std_logic_vector(6 downto 0);
  signal decoder_out_rd         : std_logic_vector(4 downto 0);
  signal decoder_out_rs1        : std_logic_vector(4 downto 0);
  signal decoder_out_rs2        : std_logic_vector(4 downto 0);
  signal decoder_out_funct3     : std_logic_vector(2 downto 0);
  signal decoder_out_funct7     : std_logic_vector(6 downto 0);
  signal decoder_out_immediate  : std_logic_vector(31 downto 0);

begin

  functional_unit_alu : component alu
    port map (
      a      => alu_in_a,
      b      => alu_in_b,
      funct3 => alu_in_funct3,
      funct7 => alu_in_funct7,
      result => alu_out_result
    );

  functional_unit_register_file : component register_file
    port map (
      register_a_select     => register_file_in_a_select,
      register_b_select     => register_file_in_b_select,
      register_write_select => register_file_in_write_select,
      data                  => register_file_in_data,
      write_enable          => register_file_in_write_enable,
      clk                   => register_file_in_clk,
      reset                 => register_file_in_reset,
      out_a                 => register_file_out_a,
      out_b                 => register_file_out_b
    );

  functional_unit_decoder : component decoder
    port map (
      instruction => decoder_in_instruction,
      opcode      => decoder_out_opcode,
      rd          => decoder_out_rd,
      rs1         => decoder_out_rs1,
      rs2         => decoder_out_rs2,
      funct3      => decoder_out_funct3,
      funct7      => decoder_out_funct7,
      immediate   => decoder_out_immediate
    );

  alu_in_a <= register_file_out_a;
  alu_in_b <= register_file_out_b when decoder_out_opcode = "0110011" else
              decoder_out_immediate when decoder_out_opcode = "0010011";

  alu_in_funct3 <= decoder_out_funct3;
  alu_in_funct7 <= decoder_out_funct7;

  register_file_in_a_select     <= decoder_out_rs1;
  register_file_in_b_select     <= decoder_out_rs2;
  register_file_in_write_select <= decoder_out_rd;
  register_file_in_data         <= alu_out_result;
  register_file_in_write_enable <= '1';
  register_file_in_clk          <= clk;
  register_file_in_reset        <= reset;

  decoder_in_instruction <= instruction;

end architecture rtl;
