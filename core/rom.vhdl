--! RV32I provides a 32-bit address space that is byte-addressed.
--! But, the "byte-addressed" thing is about data section, not the instruction section.
--! So I decided to cheat a little and provide an entity that gives you access to 32-bit cells.
--! That way each address relates to each instruction and we don't need to work with padding.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity rom is
  port (
    address : in    std_logic_vector(31 downto 0);
    data    : out   std_logic_vector(31 downto 0)
  );
end entity rom;

architecture rtl of rom is

  -- In order to simplify simulation, I made an 8-bit address space here, for now
  -- However, the 32-bit address is still required by an input in the entity
  -- We won't have issues with that unless we will go out-of-bounds here

  type rom_bank is array (0 to 255) of std_logic_vector(31 downto 0);

  -- Here, we can "flash" our firmware for testing purposes
  -- That block here is not for long, but it is here until we will have other interfaces for firmware to work
  -- vsg_disable_next_line signal_007
  signal memory : rom_bank := (
    x"3e800093",
    x"7d008113",
    x"c1810193",
    x"83018213",
    x"3e820293",
    others => (others => '0')
  );

begin

  data <= memory(to_integer(unsigned(address)));

end architecture rtl;
