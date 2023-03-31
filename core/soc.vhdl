--! System-On-Chip is a complex entity with many other entities combined here.
--! For instance, it is ok to have a hart here, RAM, ROM, some protocol implementation e.g. UART or something and so on.
--! So it will act as a top-level entity that will be synthesized in the end.
--! Later on, with the project development, more and more entities will be added here.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity soc is
  port (
    clk   : in    std_logic;
    reset : in    std_logic
  );
end entity soc;

architecture rtl of soc is

  component hart is
    port (
      instruction_bus_address : out   std_logic_vector(31 downto 0);
      instruction_bus_data    : in    std_logic_vector(31 downto 0);

      data_bus_address         : out   std_logic_vector(31 downto 0);
      data_bus_data_in         : in    std_logic_vector(31 downto 0);
      data_bus_data_out        : out   std_logic_vector(31 downto 0);
      data_bus_read_enable     : out   std_logic;
      data_bus_read_byte       : out   std_logic;
      data_bus_read_half_word  : out   std_logic;
      data_bus_read_word       : out   std_logic;
      data_bus_write_enable    : out   std_logic;
      data_bus_write_byte      : out   std_logic;
      data_bus_write_half_word : out   std_logic;
      data_bus_write_word      : out   std_logic;

      clk   : in    std_logic;
      reset : in    std_logic
    );
  end component;

  component rom is
    port (
      address : in    std_logic_vector(31 downto 0);
      data    : out   std_logic_vector(31 downto 0)
    );
  end component;

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

  -- Hart0 Signals
  signal hart0_instruction_bus_address  : std_logic_vector(31 downto 0);
  signal hart0_instruction_bus_data     : std_logic_vector(31 downto 0);
  signal hart0_data_bus_address         : std_logic_vector(31 downto 0);
  signal hart0_data_bus_data_in         : std_logic_vector(31 downto 0);
  signal hart0_data_bus_data_out        : std_logic_vector(31 downto 0);
  signal hart0_data_bus_read_enable     : std_logic;
  signal hart0_data_bus_read_byte       : std_logic;
  signal hart0_data_bus_read_half_word  : std_logic;
  signal hart0_data_bus_read_word       : std_logic;
  signal hart0_data_bus_write_enable    : std_logic;
  signal hart0_data_bus_write_byte      : std_logic;
  signal hart0_data_bus_write_half_word : std_logic;
  signal hart0_data_bus_write_word      : std_logic;
  signal hart0_clk                      : std_logic;
  signal hart0_reset                    : std_logic;

  -- Firmware Flash Signals
  signal firmware_flash_address : std_logic_vector(31 downto 0);
  signal firmware_flash_data    : std_logic_vector(31 downto 0);

  -- Random Access Memory Signals
  signal ram_address         : std_logic_vector(31 downto 0);
  signal ram_data_in         : std_logic_vector(31 downto 0);
  signal ram_data_out        : std_logic_vector(31 downto 0);
  signal ram_read_enable     : std_logic;
  signal ram_read_byte       : std_logic;
  signal ram_read_half_word  : std_logic;
  signal ram_read_word       : std_logic;
  signal ram_write_enable    : std_logic;
  signal ram_write_byte      : std_logic;
  signal ram_write_half_word : std_logic;
  signal ram_write_word      : std_logic;
  signal ram_clk             : std_logic;
  signal ram_reset           : std_logic;

begin

  hart0 : component hart
    port map (
      instruction_bus_address  => hart0_instruction_bus_address,
      instruction_bus_data     => hart0_instruction_bus_data,
      data_bus_address         => hart0_data_bus_address,
      data_bus_data_in         => hart0_data_bus_data_in,
      data_bus_data_out        => hart0_data_bus_data_out,
      data_bus_read_enable     => hart0_data_bus_read_enable,
      data_bus_read_byte       => hart0_data_bus_read_byte,
      data_bus_read_half_word  => hart0_data_bus_read_half_word,
      data_bus_read_word       => hart0_data_bus_read_word,
      data_bus_write_enable    => hart0_data_bus_write_enable,
      data_bus_write_byte      => hart0_data_bus_write_byte,
      data_bus_write_half_word => hart0_data_bus_write_half_word,
      data_bus_write_word      => hart0_data_bus_write_word,
      clk                      => hart0_clk,
      reset                    => hart0_reset
    );

  firmware_flash : component rom
    port map (
      address => firmware_flash_address,
      data    => firmware_flash_data
    );

  random_access_memory : component ram
    port map (
      address         => ram_address,
      data_in         => ram_data_in,
      data_out        => ram_data_out,
      read_enable     => ram_read_enable,
      read_byte       => ram_read_byte,
      read_half_word  => ram_read_half_word,
      read_word       => ram_read_word,
      write_enable    => ram_write_enable,
      write_byte      => ram_write_byte,
      write_half_word => ram_write_half_word,
      write_word      => ram_write_word,
      clk             => ram_clk,
      reset           => ram_reset
    );

  -- Hart0 Signals
  hart0_instruction_bus_data <= firmware_flash_data;
  hart0_data_bus_data_in     <= ram_data_out;
  hart0_clk                  <= clk;
  hart0_reset                <= reset;

  -- Firmware Flash Signals
  firmware_flash_address <= hart0_instruction_bus_address;

  -- Random Access Memory Signals
  ram_address         <= hart0_data_bus_address;
  ram_data_in         <= hart0_data_bus_data_out;
  ram_read_enable     <= hart0_data_bus_read_enable;
  ram_read_byte       <= hart0_data_bus_read_byte;
  ram_read_half_word  <= hart0_data_bus_read_half_word;
  ram_read_word       <= hart0_data_bus_read_word;
  ram_write_enable    <= hart0_data_bus_write_enable;
  ram_write_byte      <= hart0_data_bus_write_byte;
  ram_write_half_word <= hart0_data_bus_write_half_word;
  ram_write_word      <= hart0_data_bus_write_word;
  ram_clk             <= clk;
  ram_reset           <= reset;

end architecture rtl;
