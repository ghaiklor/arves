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
    instruction_bus_address : out   std_logic_vector(31 downto 0);
    instruction_bus_data    : in    std_logic_vector(31 downto 0);

    clk   : in    std_logic;
    reset : in    std_logic
  );
end entity hart;

architecture rtl of hart is

  component alu is
    port (
      a      : in    std_logic_vector(31 downto 0);
      b      : in    std_logic_vector(31 downto 0);
      opcode : in    std_logic_vector(6 downto 0);
      funct3 : in    std_logic_vector(2 downto 0);
      funct7 : in    std_logic_vector(6 downto 0);
      result : out   std_logic_vector(31 downto 0)
    );
  end component;

  component register_file is
    port (
      select_a : in    std_logic_vector(4 downto 0);
      data_a   : out   std_logic_vector(31 downto 0);

      select_b : in    std_logic_vector(4 downto 0);
      data_b   : out   std_logic_vector(31 downto 0);

      select_write : in    std_logic_vector(4 downto 0);
      data_write   : in    std_logic_vector(31 downto 0);
      write_enable : in    std_logic;

      clk   : in    std_logic;
      reset : in    std_logic
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

  component program_counter is
    port (
      address : out   std_logic_vector(31 downto 0);

      write_address : in    std_logic_vector(31 downto 0);
      write_enable  : in    std_logic;

      clk   : in    std_logic;
      reset : in    std_logic
    );
  end component;

  -- ALU Signals
  signal alu_in_a       : std_logic_vector(31 downto 0);
  signal alu_in_b       : std_logic_vector(31 downto 0);
  signal alu_in_opcode  : std_logic_vector(6 downto 0);
  signal alu_in_funct3  : std_logic_vector(2 downto 0);
  signal alu_in_funct7  : std_logic_vector(6 downto 0);
  signal alu_out_result : std_logic_vector(31 downto 0);

  -- Register File Signals
  signal register_file_in_select_a     : std_logic_vector(4 downto 0);
  signal register_file_in_select_b     : std_logic_vector(4 downto 0);
  signal register_file_in_select_write : std_logic_vector(4 downto 0);
  signal register_file_in_data_write   : std_logic_vector(31 downto 0);
  signal register_file_in_write_enable : std_logic;
  signal register_file_in_clk          : std_logic;
  signal register_file_in_reset        : std_logic;
  signal register_file_out_data_a      : std_logic_vector(31 downto 0);
  signal register_file_out_data_b      : std_logic_vector(31 downto 0);

  -- Decoder Signals
  signal decoder_in_instruction : std_logic_vector(31 downto 0);
  signal decoder_out_opcode     : std_logic_vector(6 downto 0);
  signal decoder_out_rd         : std_logic_vector(4 downto 0);
  signal decoder_out_rs1        : std_logic_vector(4 downto 0);
  signal decoder_out_rs2        : std_logic_vector(4 downto 0);
  signal decoder_out_funct3     : std_logic_vector(2 downto 0);
  signal decoder_out_funct7     : std_logic_vector(6 downto 0);
  signal decoder_out_immediate  : std_logic_vector(31 downto 0);

  -- Program Counter Signals
  signal program_counter_out_address      : std_logic_vector(31 downto 0);
  signal program_counter_in_write_address : std_logic_vector(31 downto 0);
  signal program_counter_in_write_enable  : std_logic;
  signal program_counter_in_clk           : std_logic;
  signal program_counter_in_reset         : std_logic;

begin

  functional_unit_alu : component alu
    port map (
      a      => alu_in_a,
      b      => alu_in_b,
      opcode => alu_in_opcode,
      funct3 => alu_in_funct3,
      funct7 => alu_in_funct7,
      result => alu_out_result
    );

  functional_unit_register_file : component register_file
    port map (
      select_a     => register_file_in_select_a,
      data_a       => register_file_out_data_a,
      select_b     => register_file_in_select_b,
      data_b       => register_file_out_data_b,
      select_write => register_file_in_select_write,
      data_write   => register_file_in_data_write,
      write_enable => register_file_in_write_enable,
      clk          => register_file_in_clk,
      reset        => register_file_in_reset
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

  functional_unit_program_counter : component program_counter
    port map (
      address       => program_counter_out_address,
      write_address => program_counter_in_write_address,
      write_enable  => program_counter_in_write_enable,
      clk           => program_counter_in_clk,
      reset         => program_counter_in_reset
    );

  -- ALU Signals
  alu_in_a <= register_file_out_data_a;
  alu_in_b <= register_file_out_data_b when decoder_out_opcode = "0110011" else
              decoder_out_immediate when decoder_out_opcode = "0010011" else
              (others => '0');

  alu_in_opcode <= decoder_out_opcode;
  alu_in_funct3 <= decoder_out_funct3;
  alu_in_funct7 <= decoder_out_funct7;

  -- Register File Signals
  register_file_in_select_a     <= decoder_out_rs1;
  register_file_in_select_b     <= decoder_out_rs2;
  register_file_in_select_write <= decoder_out_rd;
  register_file_in_data_write   <= alu_out_result;
  register_file_in_write_enable <= '1';
  register_file_in_clk          <= clk;
  register_file_in_reset        <= reset;

  -- Decoder Signals
  decoder_in_instruction <= instruction_bus_data;

  -- Program Counter Signals
  program_counter_in_write_address <= std_logic_vector(to_unsigned(0, program_counter_in_write_address'length));
  program_counter_in_write_enable  <= '0';
  program_counter_in_clk           <= clk;
  program_counter_in_reset         <= reset;

  -- Entity Signals
  instruction_bus_address <= program_counter_out_address;

end architecture rtl;
