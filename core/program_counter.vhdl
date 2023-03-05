--! Program Counter is a unprivileged register that holds the address of the current instruction.
--! Since the address space of the RISC-V processor depends on the architecture, we can have 32 or 64 bits for address.
--! Also, the address can be overridden in the case of branch instructions or jump instructions.
--! So that, the inputs on the entity can be used to override the address of the instruction.
--! Otherwise, we increment it by one on each clock cycle when needed.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity program_counter is
  port (
    address : out   std_logic_vector(31 downto 0);

    write_address : in    std_logic_vector(31 downto 0);
    write_enable  : in    std_logic;

    clk   : in    std_logic;
    reset : in    std_logic
  );
end entity program_counter;

architecture rtl of program_counter is

  signal pc : std_logic_vector(31 downto 0);

begin

  address <= pc;

  tick : process (clk, reset) is
  begin

    if (reset = '1') then
      pc <= std_logic_vector(to_unsigned(0, pc'length));
    elsif (rising_edge(clk) and write_enable = '1') then
      pc <= write_address;
    elsif (rising_edge(clk) and write_enable = '0') then
      pc <= std_logic_vector(unsigned(pc) + to_unsigned(1, pc'length));
    end if;

  end process tick;

end architecture rtl;
