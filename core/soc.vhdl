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

  component rom is
    port (
      address : in    std_logic_vector(31 downto 0);
      data    : out   std_logic_vector(31 downto 0)
    );
  end component;

  component hart is
    port (
      instruction         : in    std_logic_vector(31 downto 0);
      clk                 : in    std_logic;
      reset               : in    std_logic;
      instruction_address : out   std_logic_vector(31 downto 0)
    );
  end component;

  -- Firmware Flash Signals
  signal firmware_flash_in_address : std_logic_vector(31 downto 0);
  signal firmware_flash_out_data   : std_logic_vector(31 downto 0);

  -- Hardware Thread Signals
  signal hart_in_instruction          : std_logic_vector(31 downto 0);
  signal hart_in_clk                  : std_logic;
  signal hart_in_reset                : std_logic;
  signal hart_out_instruction_address : std_logic_vector(31 downto 0);

begin

  hart0 : component hart
    port map (
      instruction         => hart_in_instruction,
      clk                 => hart_in_clk,
      reset               => hart_in_reset,
      instruction_address => hart_out_instruction_address
    );

  firmware_flash : component rom
    port map (
      address => firmware_flash_in_address,
      data    => firmware_flash_out_data
    );

  firmware_flash_in_address <= hart_out_instruction_address;

  hart_in_instruction <= firmware_flash_out_data;
  hart_in_clk         <= clk;
  hart_in_reset       <= reset;

end architecture rtl;
