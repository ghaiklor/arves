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

  type rom_bank is array (0 to 65536) of std_logic_vector(7 downto 0);

  -- Here, we can "flash" our firmware for testing purposes
  -- That block here is not for long, but it is here until we will have other interfaces for firmware to work
  -- vsg_disable_next_line signal_007
  signal memory : rom_bank := (
    x"93",
    x"00",
    x"80",
    x"3e",
    x"13",
    x"81",
    x"00",
    x"7d",
    x"ef",
    x"01",
    x"c0",
    x"00",
    x"93",
    x"01",
    x"81",
    x"c1",
    x"13",
    x"82",
    x"01",
    x"83",
    x"93",
    x"02",
    x"82",
    x"3e",
    others => (others => '0')
  );

begin

  data <= memory(to_integer(unsigned(address) + 3)) &
          memory(to_integer(unsigned(address) + 2)) &
          memory(to_integer(unsigned(address) + 1)) &
          memory(to_integer(unsigned(address)));

end architecture rtl;
