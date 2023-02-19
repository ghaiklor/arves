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

  stimuli : process is

    constant propagation_time : time := 1 ns;

  begin

    -- RESET
    clk   <= '0';
    reset <= '1';
    wait for propagation_time;
    reset <= '0';

    -- Driving the clock
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;
    clk <= not clk;
    wait for propagation_time;

    assert false
      report "test bench for System-On-Chip is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
