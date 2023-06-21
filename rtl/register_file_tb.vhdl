--! In order to check register file, I wrote a simple scenario.
--! What it does is just writes into registers x1, x2 and x3.
--! Switching between different registers A and B, I am checking if values are correct there.
--! It is enough to check if the register file is working at all (smoke testing).

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity register_file_tb is
end entity register_file_tb;

architecture tb of register_file_tb is

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

  signal select_a     : std_logic_vector(4 downto 0);
  signal data_a       : std_logic_vector(31 downto 0);
  signal select_b     : std_logic_vector(4 downto 0);
  signal data_b       : std_logic_vector(31 downto 0);
  signal select_write : std_logic_vector(4 downto 0);
  signal data_write   : std_logic_vector(31 downto 0);
  signal write_enable : std_logic;
  signal clk          : std_logic;
  signal reset        : std_logic;

begin

  uut : component register_file
    port map (
      select_a     => select_a,
      data_a       => data_a,
      select_b     => select_b,
      data_b       => data_b,
      select_write => select_write,
      data_write   => data_write,
      write_enable => write_enable,
      clk          => clk,
      reset        => reset
    );

  stimuli : process is

    constant propagation_time : time := 1 ns;

  begin

    -- RESET
    select_a     <= std_logic_vector(to_unsigned(1, select_a'length));
    select_b     <= std_logic_vector(to_unsigned(2, select_b'length));
    select_write <= std_logic_vector(to_unsigned(3, select_write'length));
    data_write   <= std_logic_vector(to_signed(4, data_write'length));
    write_enable <= '0';
    clk          <= '0';
    reset        <= '1';
    wait for propagation_time;
    assert data_a = std_logic_vector(to_unsigned(0, data_a'length))
      report "data_a must be 0"
      severity error;
    assert data_b = std_logic_vector(to_unsigned(0, data_b'length))
      report "data_b must be 0"
      severity error;

    -- Write 32 to register x1
    -- li x1, 32
    select_a     <= std_logic_vector(to_unsigned(1, select_a'length));
    select_b     <= std_logic_vector(to_unsigned(2, select_b'length));
    select_write <= std_logic_vector(to_unsigned(1, select_write'length));
    data_write   <= std_logic_vector(to_signed(32, data_write'length));
    write_enable <= '1';
    clk          <= '0';
    reset        <= '0';
    wait for propagation_time;
    clk          <= '1';
    wait for propagation_time;
    assert data_a = std_logic_vector(to_unsigned(32, data_a'length))
      report "data_a must be 32"
      severity error;
    assert data_b = std_logic_vector(to_unsigned(0, data_b'length))
      report "data_b must be 0"
      severity error;

    -- Write 64 to register x2
    -- li x2, 64
    select_a     <= std_logic_vector(to_unsigned(1, select_a'length));
    select_b     <= std_logic_vector(to_unsigned(2, select_b'length));
    select_write <= std_logic_vector(to_unsigned(2, select_write'length));
    data_write   <= std_logic_vector(to_signed(64, data_write'length));
    write_enable <= '1';
    clk          <= '0';
    reset        <= '0';
    wait for propagation_time;
    clk          <= '1';
    wait for propagation_time;
    assert data_a = std_logic_vector(to_unsigned(32, data_a'length))
      report "data_a must be 32"
      severity error;
    assert data_b = std_logic_vector(to_unsigned(64, data_b'length))
      report "data_b must be 64"
      severity error;

    -- Write 128 to register x3
    -- li x3, 128
    select_a     <= std_logic_vector(to_unsigned(3, select_a'length));
    select_b     <= std_logic_vector(to_unsigned(2, select_b'length));
    select_write <= std_logic_vector(to_unsigned(3, select_write'length));
    data_write   <= std_logic_vector(to_signed(128, data_write'length));
    write_enable <= '1';
    clk          <= '0';
    reset        <= '0';
    wait for propagation_time;
    clk          <= '1';
    wait for propagation_time;
    assert data_a = std_logic_vector(to_unsigned(128, data_a'length))
      report "data_a must be 128"
      severity error;
    assert data_b = std_logic_vector(to_unsigned(64, data_b'length))
      report "data_b must be 64"
      severity error;

    -- Writing does not occur with de-asserted write_enable pin
    select_a     <= std_logic_vector(to_unsigned(1, select_a'length));
    select_b     <= std_logic_vector(to_unsigned(2, select_b'length));
    select_write <= std_logic_vector(to_unsigned(1, select_write'length));
    data_write   <= std_logic_vector(to_signed(128, data_write'length));
    write_enable <= '0';
    clk          <= '0';
    reset        <= '0';
    wait for propagation_time;
    clk          <= '1';
    wait for propagation_time;
    assert data_a = std_logic_vector(to_unsigned(32, data_a'length))
      report "data_a must be 32"
      severity error;
    assert data_b = std_logic_vector(to_unsigned(64, data_b'length))
      report "data_b must be 64"
      severity error;

    -- Writing to x0 does not change it
    select_a <= std_logic_vector(to_unsigned(0, select_a'length));
    select_b <= std_logic_vector(to_unsigned(0, select_a'length));
    select_write <= std_logic_vector(to_unsigned(0, select_write'length));
    data_write   <= std_logic_vector(to_unsigned(255, data_write'length));
    write_enable <= '0';

    clk <= '0';
    wait for propagation_time;
    assert data_a = std_logic_vector(to_unsigned(0, data_a'length))
      report "reading x0: data_a must be 0"
      severity error;

    write_enable <= '1';
    clk <= '1';
    wait for propagation_time;
    assert data_a = std_logic_vector(to_unsigned(0, data_a'length))
      report "reading x0 after write: data_a must be 0"
      severity error;

    -- done
    assert false
      report "test bench for register file is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
