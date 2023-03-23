library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity ram_tb is
end entity ram_tb;

architecture tb of ram_tb is

  component ram is
    port (
      address  : in    std_logic_vector(31 downto 0);
      data_in  : in    std_logic_vector(31 downto 0);
      data_out : out   std_logic_vector(31 downto 0);

      read_enable    : in    std_logic;
      read_byte      : in    std_logic;
      read_half_word : in    std_logic;
      read_word      : in    std_logic;

      write_enable    : in    std_logic;
      write_byte      : in    std_logic;
      write_half_word : in    std_logic;
      write_word      : in    std_logic;

      clk   : in    std_logic;
      reset : in    std_logic
    );
  end component;

  signal address         : std_logic_vector(31 downto 0);
  signal data_in         : std_logic_vector(31 downto 0);
  signal data_out        : std_logic_vector(31 downto 0);
  signal read_enable     : std_logic;
  signal read_byte       : std_logic;
  signal read_half_word  : std_logic;
  signal read_word       : std_logic;
  signal write_enable    : std_logic;
  signal write_byte      : std_logic;
  signal write_half_word : std_logic;
  signal write_word      : std_logic;
  signal clk             : std_logic;
  signal reset           : std_logic;

begin

  uut : component ram
    port map (
      address         => address,
      data_in         => data_in,
      data_out        => data_out,
      read_enable     => read_enable,
      read_byte       => read_byte,
      read_half_word  => read_half_word,
      read_word       => read_word,
      write_enable    => write_enable,
      write_byte      => write_byte,
      write_half_word => write_half_word,
      write_word      => write_word,
      clk             => clk,
      reset           => reset
    );

  stimuli : process is

    constant propagation_time : time := 1 ns;

  begin

    -- RESET
    address         <= std_logic_vector(to_unsigned(0, address'length));
    data_in         <= std_logic_vector(to_signed(0, data_in'length));
    read_enable     <= '0';
    read_byte       <= '0';
    read_half_word  <= '0';
    read_word       <= '0';
    write_enable    <= '0';
    write_byte      <= '0';
    write_half_word <= '0';
    write_word      <= '0';
    clk             <= '0';
    reset           <= '1';
    wait for propagation_time;
    reset           <= '0';

    -- Write 127 to 4
    address         <= std_logic_vector(to_unsigned(4, address'length));
    data_in         <= std_logic_vector(to_signed(127, data_in'length));
    read_enable     <= '0';
    read_byte       <= '0';
    read_half_word  <= '0';
    read_word       <= '0';
    write_enable    <= '1';
    write_byte      <= '1';
    write_half_word <= '1';
    write_word      <= '1';
    clk             <= '0';
    reset           <= '0';
    wait for propagation_time;
    clk             <= '1';
    wait for propagation_time;

    -- Write 2147483647 to 8
    address         <= std_logic_vector(to_unsigned(8, address'length));
    data_in         <= std_logic_vector(to_signed(2147483647, data_in'length));
    read_enable     <= '0';
    read_byte       <= '0';
    read_half_word  <= '0';
    read_word       <= '0';
    write_enable    <= '1';
    write_byte      <= '1';
    write_half_word <= '1';
    write_word      <= '1';
    clk             <= '0';
    reset           <= '0';
    wait for propagation_time;
    clk             <= '1';
    wait for propagation_time;

    -- Read from 8 must be 2147483647
    address         <= std_logic_vector(to_unsigned(8, address'length));
    data_in         <= std_logic_vector(to_signed(0, data_in'length));
    read_enable     <= '1';
    read_byte       <= '1';
    read_half_word  <= '1';
    read_word       <= '1';
    write_enable    <= '0';
    write_byte      <= '0';
    write_half_word <= '0';
    write_word      <= '0';
    clk             <= '0';
    reset           <= '0';
    wait for propagation_time;
    clk             <= '1';
    wait for propagation_time;
    assert data_out = std_logic_vector(to_signed(2147483647, data_out'length))
      report "read from #8 must be 2147483647"
      severity error;

    -- Read from 8 must be 65535 (half-word)
    address         <= std_logic_vector(to_unsigned(8, address'length));
    data_in         <= std_logic_vector(to_signed(0, data_in'length));
    read_enable     <= '1';
    read_byte       <= '1';
    read_half_word  <= '1';
    read_word       <= '0';
    write_enable    <= '0';
    write_byte      <= '0';
    write_half_word <= '0';
    write_word      <= '0';
    clk             <= '0';
    reset           <= '0';
    wait for propagation_time;
    clk             <= '1';
    wait for propagation_time;
    assert data_out = std_logic_vector(to_signed(65535, data_out'length))
      report "read from #8 must be 65535"
      severity error;

    assert false
      report "test bench for random access memory is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
