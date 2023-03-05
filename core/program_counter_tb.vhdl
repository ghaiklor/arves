library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity program_counter_tb is
end entity program_counter_tb;

architecture tb of program_counter_tb is

  component program_counter is
    port (
      address : out   std_logic_vector(31 downto 0);

      write_address : in    std_logic_vector(31 downto 0);
      write_enable  : in    std_logic;

      clk   : in    std_logic;
      reset : in    std_logic
    );
  end component;

  signal address       : std_logic_vector(31 downto 0);
  signal write_address : std_logic_vector(31 downto 0);
  signal write_enable  : std_logic;
  signal clk           : std_logic;
  signal reset         : std_logic;

begin

  uut : component program_counter
    port map (
      address       => address,
      write_address => write_address,
      write_enable  => write_enable,
      clk           => clk,
      reset         => reset
    );

  stimuli : process is

    constant propagation_time : time := 1 ns;

  begin

    -- RESET
    write_address <= std_logic_vector(to_unsigned(0, write_address'length));
    write_enable  <= '0';
    clk           <= '0';
    reset         <= '1';
    wait for propagation_time;
    assert address = std_logic_vector(to_unsigned(0, address'length))
      report "Instruction Address must be 0 on reset"
      severity error;

    -- Override the address of instruction
    write_address <= std_logic_vector(to_unsigned(127, write_address'length));
    write_enable  <= '1';
    clk           <= '0';
    reset         <= '0';
    wait for propagation_time;
    clk           <= '1';
    wait for propagation_time;
    assert address = std_logic_vector(to_unsigned(127, address'length))
      report "Instruction Address must be 127 on override"
      severity error;

    -- In usual scenario it must increment the address by one
    write_address <= std_logic_vector(to_unsigned(127, write_address'length));
    write_enable  <= '0';
    clk           <= '0';
    reset         <= '0';
    wait for propagation_time;
    clk           <= '1';
    wait for propagation_time;
    assert address = std_logic_vector(to_unsigned(128, address'length))
      report "Instruction Address must be 128 on clock cycle"
      severity error;

    assert false
      report "testbench for program counter is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
