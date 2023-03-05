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
      address : out   std_logic_vector(31 downto 0);
      data    : inout std_logic_vector(31 downto 0);

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

  -- Hart0 Signals
  signal hart0_out_address : std_logic_vector(31 downto 0);
  signal hart0_inout_data  : std_logic_vector(31 downto 0);
  signal hart0_in_clk      : std_logic;
  signal hart0_in_reset    : std_logic;

  -- Firmware Flash Signals
  signal firmware_flash_address : std_logic_vector(31 downto 0);
  signal firmware_flash_data    : std_logic_vector(31 downto 0);

begin

  hart0 : component hart
    port map (
      address => hart0_out_address,
      data    => hart0_inout_data,
      clk     => hart0_in_clk,
      reset   => hart0_in_reset
    );

  firmware_flash : component rom
    port map (
      address => firmware_flash_address,
      data    => firmware_flash_data
    );

  hart0_inout_data <= firmware_flash_data;
  hart0_in_clk     <= clk;
  hart0_in_reset   <= reset;

  firmware_flash_address <= hart0_out_address;

end architecture rtl;
