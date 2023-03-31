--! RV32I has 32 registers, each 32 bits wide.
--! However, the length of the registers can also be 64 bits in RV64I.
--! So, the length of the register dictated by the architecture we are implementing.
--!
--! One of these registers is unique in a way that bits of the register hardwired to 0.
--! Meaning, we can't really write to it and update its value.
--! It will be always 0, no matter what.
--! This register is the register x0.
--!
--! Other registers are registers x1, x2, x3, ..., x31.
--! They are general purpose registers that hold values and can be interpreted as a:
--! collection of boolean values, two's complement signed integers or unsigned integers.
--!
--! There is also one additional register.
--! This register is the program counter (PC) register that holds the address of the current instruction.
--! However, I think that it makes little sense to have this register here.
--! So that, this register file does not contain the program counter register.
--! Instead, it will be created in the control unit or somewhere in between.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity register_file is
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
end entity register_file;

architecture rtl of register_file is

  type register_bank is array (0 to 31) of std_logic_vector(31 downto 0);

  signal registers : register_bank;

begin

  data_a <= registers(to_integer(unsigned(select_a)));
  data_b <= registers(to_integer(unsigned(select_b)));

  write : process (clk, reset) is
  begin

    if (reset = '1') then
      registers <= (others => (others => '0'));
    elsif (rising_edge(clk) and write_enable = '1') then
      registers(to_integer(unsigned(select_write))) <= data_write;
    end if;

  end process write;

end architecture rtl;
