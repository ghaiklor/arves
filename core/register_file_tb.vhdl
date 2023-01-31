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

  for uut: register_file use entity work.register_file;

  signal register_a_select     : std_logic_vector(4 downto 0);
  signal register_b_select     : std_logic_vector(4 downto 0);
  signal register_write_select : std_logic_vector(4 downto 0);
  signal data                  : std_logic_vector(31 downto 0);
  signal write_enable          : std_logic;
  signal clk                   : std_logic;
  signal reset                 : std_logic;
  signal out_a                 : std_logic_vector(31 downto 0);
  signal out_b                 : std_logic_vector(31 downto 0);

begin

  uut : component register_file
    port map (
      register_a_select     => register_a_select,
      register_b_select     => register_b_select,
      register_write_select => register_write_select,
      data                  => data,
      write_enable          => write_enable,
      clk                   => clk,
      reset                 => reset,
      out_a                 => out_a,
      out_b                 => out_b
    );

  stimuli : process is

    constant propagation_time : time := 1 ns;

  begin

    -- RESET
    register_a_select     <= std_logic_vector(to_unsigned(1, register_a_select'length));
    register_b_select     <= std_logic_vector(to_unsigned(2, register_b_select'length));
    register_write_select <= std_logic_vector(to_unsigned(3, register_write_select'length));
    data                  <= std_logic_vector(to_signed(4, data'length));
    write_enable          <= '0';
    clk                   <= '0';
    reset                 <= '1';
    wait for propagation_time;
    assert out_a = std_logic_vector(to_unsigned(0, out_a'length))
      report "out_a must be 0"
      severity error;
    assert out_b = std_logic_vector(to_unsigned(0, out_b'length))
      report "out_b must be 0"
      severity error;

    -- Write 32 to register x1
    -- li x1, 32
    register_a_select     <= std_logic_vector(to_unsigned(1, register_a_select'length));
    register_b_select     <= std_logic_vector(to_unsigned(2, register_b_select'length));
    register_write_select <= std_logic_vector(to_unsigned(1, register_write_select'length));
    data                  <= std_logic_vector(to_signed(32, data'length));
    write_enable          <= '1';
    clk                   <= '0';
    reset                 <= '0';
    wait for propagation_time;
    clk                   <= '1';
    wait for propagation_time;
    assert out_a = std_logic_vector(to_unsigned(32, out_a'length))
      report "out_a must be 32"
      severity error;
    assert out_b = std_logic_vector(to_unsigned(0, out_b'length))
      report "out_b must be 0"
      severity error;

    -- Write 64 to register x2
    -- li x2, 64
    register_a_select     <= std_logic_vector(to_unsigned(1, register_a_select'length));
    register_b_select     <= std_logic_vector(to_unsigned(2, register_b_select'length));
    register_write_select <= std_logic_vector(to_unsigned(2, register_write_select'length));
    data                  <= std_logic_vector(to_signed(64, data'length));
    write_enable          <= '1';
    clk                   <= '0';
    reset                 <= '0';
    wait for propagation_time;
    clk                   <= '1';
    wait for propagation_time;
    assert out_a = std_logic_vector(to_unsigned(32, out_a'length))
      report "out_a must be 32"
      severity error;
    assert out_b = std_logic_vector(to_unsigned(64, out_b'length))
      report "out_b must be 64"
      severity error;

    -- Write 128 to register x3
    -- li x3, 128
    register_a_select     <= std_logic_vector(to_unsigned(3, register_a_select'length));
    register_b_select     <= std_logic_vector(to_unsigned(2, register_b_select'length));
    register_write_select <= std_logic_vector(to_unsigned(3, register_write_select'length));
    data                  <= std_logic_vector(to_signed(128, data'length));
    write_enable          <= '1';
    clk                   <= '0';
    reset                 <= '0';
    wait for propagation_time;
    clk                   <= '1';
    wait for propagation_time;
    assert out_a = std_logic_vector(to_unsigned(128, out_a'length))
      report "out_a must be 128"
      severity error;
    assert out_b = std_logic_vector(to_unsigned(64, out_b'length))
      report "out_b must be 64"
      severity error;

    -- Writing does not occur with de-asserted write_enable pin
    register_a_select     <= std_logic_vector(to_unsigned(1, register_a_select'length));
    register_b_select     <= std_logic_vector(to_unsigned(2, register_b_select'length));
    register_write_select <= std_logic_vector(to_unsigned(1, register_write_select'length));
    data                  <= std_logic_vector(to_signed(128, data'length));
    write_enable          <= '0';
    clk                   <= '0';
    reset                 <= '0';
    wait for propagation_time;
    clk                   <= '1';
    wait for propagation_time;
    assert out_a = std_logic_vector(to_unsigned(32, out_a'length))
      report "out_a must be 32"
      severity error;
    assert out_b = std_logic_vector(to_unsigned(64, out_b'length))
      report "out_b must be 64"
      severity error;

    wait for propagation_time;

    assert false
      report "test bench for register file is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
