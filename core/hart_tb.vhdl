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
      instruction         : in    std_logic_vector(31 downto 0);
      clk                 : in    std_logic;
      reset               : in    std_logic;
      instruction_address : out   std_logic_vector(31 downto 0)
    );
  end component;

  signal instruction         : std_logic_vector(31 downto 0);
  signal clk                 : std_logic;
  signal reset               : std_logic;
  signal instruction_address : std_logic_vector(31 downto 0);

begin

  uut : component hart
    port map (
      instruction         => instruction,
      clk                 => clk,
      reset               => reset,
      instruction_address => instruction_address
    );

  stimuli : process is

    constant propagation_time : time := 1 ns;

  begin

    -- RESET
    -- Get the hart state into initial one
    clk   <= '0';
    reset <= '1';
    wait for propagation_time;
    reset <= '0';
    assert instruction_address = std_logic_vector(to_unsigned(0, instruction_address'length))
      report "Instruction Address must be equal to zero on reset"
      severity error;

    -- addi x1, x1, 32
    -- 00000010000000001000000010010011
    instruction <= "00000010000000001000000010010011";
    wait for propagation_time;
    clk         <= not clk;
    wait for propagation_time;
    clk         <= not clk;
    assert instruction_address = std_logic_vector(to_unsigned(1, instruction_address'length))
      report "Instruction Address must be equal to 1"
      severity error;

    -- addi x1, x1, 32
    -- 00000010000000001000000010010011
    instruction <= "00000010000000001000000010010011";
    wait for propagation_time;
    clk         <= not clk;
    wait for propagation_time;
    clk         <= not clk;
    assert instruction_address = std_logic_vector(to_unsigned(2, instruction_address'length))
      report "Instruction Address must be equal to 2"
      severity error;

    assert false
      report "test bench for hart is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
