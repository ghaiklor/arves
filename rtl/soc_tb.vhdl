library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity soc_tb is
end entity soc_tb;

architecture tb of soc_tb is

  component soc is
    port (
      clk   : in    std_logic;
      reset : in    std_logic
    );
  end component;

  signal clk   : std_logic;
  signal reset : std_logic;

begin

  uut : component soc
    port map (
      clk   => clk,
      reset => reset
    );

  clocker : process is

    constant clock_cycle_count  : integer := 5;
    constant clock_cycle_period : time    := 1 ns;

  begin

    clk <= '0';
    wait for clock_cycle_period;

    for i in 1 to clock_cycle_count loop

      clk <= not clk;
      wait for clock_cycle_period;
      clk <= not clk;
      wait for clock_cycle_period;

    end loop;

    wait;

  end process clocker;

  stimuli : process is

  begin

    -- RESET
    reset <= '1';
    wait for 1 ns;
    reset <= '0';

    assert false
      report "test bench for System-On-Chip is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
