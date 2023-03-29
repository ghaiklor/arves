--! There is a simple testing scenario and I'm not going to write more of them here.
--! Later on, RISC-V Test SIG will be integrated, so I will be using test generators for machine instructions.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity hart_tb is
end entity hart_tb;

architecture tb of hart_tb is

  component hart is
    port (
      instruction_bus_address : out   std_logic_vector(31 downto 0);
      instruction_bus_data    : in    std_logic_vector(31 downto 0);

      clk   : in    std_logic;
      reset : in    std_logic
    );
  end component;

  signal instruction_bus_address : std_logic_vector(31 downto 0);
  signal instruction_bus_data    : std_logic_vector(31 downto 0);
  signal clk                     : std_logic;
  signal reset                   : std_logic;

begin

  uut : component hart
    port map (
      instruction_bus_address => instruction_bus_address,
      instruction_bus_data    => instruction_bus_data,
      clk                     => clk,
      reset                   => reset
    );

  stimuli : process is

    constant propagation_time : time := 1 ns;

  begin

    -- RESET
    -- Get the hart state into initial one
    instruction_bus_data <= (others => '0');
    clk                  <= '0';
    reset                <= '1';
    wait for propagation_time;
    assert instruction_bus_address = std_logic_vector(to_unsigned(0, instruction_bus_address'length))
      report "Address must be equal to zero on reset"
      severity error;

    -- addi x1, x1, 32
    -- 00000010000000001000000010010011
    instruction_bus_data <= "00000010000000001000000010010011";
    clk                  <= '0';
    reset                <= '0';
    wait for propagation_time;
    clk                  <= '1';
    wait for propagation_time;
    assert instruction_bus_address = std_logic_vector(to_unsigned(1, instruction_bus_address'length))
      report "Address must be 0 + 1 on clock cycle"
      severity error;

    -- addi x1, x1, 32
    -- 00000010000000001000000010010011
    instruction_bus_data <= "00000010000000001000000010010011";
    clk                  <= '0';
    reset                <= '0';
    wait for propagation_time;
    clk                  <= '1';
    wait for propagation_time;
    assert instruction_bus_address = std_logic_vector(to_unsigned(2, instruction_bus_address'length))
      report "Address must be 1 + 1 on clock cycle"
      severity error;

    assert false
      report "test bench for hart is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
