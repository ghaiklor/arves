library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity rom_tb is
end entity rom_tb;

architecture tb of rom_tb is

  component rom is
    port (
      address : in    std_logic_vector(31 downto 0);
      data    : out   std_logic_vector(31 downto 0)
    );
  end component;

  signal address : std_logic_vector(31 downto 0);
  signal data    : std_logic_vector(31 downto 0);

begin

  uut : component rom
    port map (
      address => address,
      data    => data
    );

  stimuli : process is

    constant propagation_time : time := 1 ns;

  begin

    address <= std_logic_vector(to_unsigned(0, address'length));
    wait for propagation_time;
    assert data = x"3e800093"
      report "Cell #0 must have a value 3e800093"
      severity error;

    address <= std_logic_vector(to_unsigned(1, address'length));
    wait for propagation_time;
    assert data = x"7d008113"
      report "Cell #1 must have a value 7d008113"
      severity error;

    address <= std_logic_vector(to_unsigned(2, address'length));
    wait for propagation_time;
    assert data = x"c1810193"
      report "Cell #2 must have a value c1810193"
      severity error;

    assert false
      report "test bench for ROM done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
