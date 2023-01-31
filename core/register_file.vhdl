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
    --! Selection vector for Register A.
    --! Value of Register A will be sent to output A.
    register_a_select : in    std_logic_vector(4 downto 0);

    --! Selection vector for Register B.
    --! Value of Register B will be sent to output B.
    register_b_select : in    std_logic_vector(4 downto 0);

    --! Selection vector for Register to write.
    --! Value from data input will be sent to this register.
    register_write_select : in    std_logic_vector(4 downto 0);

    --! Data to write into register file.
    --! This data will be sent to register, selected by register_write_select.
    data : in    std_logic_vector(31 downto 0);

    --! Logic bit to enable register file for writing.
    --! When de-asserted, whatever the register_write_select and data, it will not be written.
    write_enable : in    std_logic;

    --! Clock signal to synchronize writing.
    --! The state of register file will be updating only on rising edge of the signal.
    clk : in    std_logic;

    --! Reset signal to set all registers values to zero.
    --! It is asynchronous signal, meaning it is not tight to clock signal.
    reset : in    std_logic;

    --! Data vector of value from Register A.
    --! Register A is selected by register_a_select input.
    out_a : out   std_logic_vector(31 downto 0);

    --! Data vector of value from Register B.
    --! Register B is selected by register_b_select input.
    out_b : out   std_logic_vector(31 downto 0)
  );
end entity register_file;

architecture rtl of register_file is

  type register_bank is array (0 to 31) of std_logic_vector(31 downto 0);

  signal registers : register_bank;

begin

  out_a <= registers(to_integer(unsigned(register_a_select)));
  out_b <= registers(to_integer(unsigned(register_b_select)));

  clock : process (clk, reset) is
  begin

    if (reset = '1') then
      registers <= (others => (others => '0'));
    elsif (rising_edge(clk) and write_enable = '1') then
      registers(to_integer(unsigned(register_write_select))) <= data;
    end if;

  end process clock;

end architecture rtl;
