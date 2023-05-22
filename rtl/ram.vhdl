--! RV32I is a load-store architecture, where only load and store instructions access memory.
--! Arithmetic instructions only operate on CPU registers and don't have access to the main memory.
--!
--! RV32I provides a 32-bit address space that is byte-addressed.
--! Meaning, we need to have a 32 bits for the address bus and 32 bit for the data bus.
--! However, since the memory is byte-addressed, we need to split data into chunks and store it in different cells.
--! The same applies to reading the data, we need to read 4 cells and combine them into 32 bits of data.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_textio.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library std;
  use std.textio.all;

entity ram is
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
end entity ram;

architecture rtl of ram is

  type ram_bank is array (0 to 65536) of std_logic_vector(7 downto 0);

  signal memory : ram_bank;

  signal data_out_0 : std_logic_vector(7 downto 0);
  signal data_out_1 : std_logic_vector(7 downto 0);
  signal data_out_2 : std_logic_vector(7 downto 0);
  signal data_out_3 : std_logic_vector(7 downto 0);

begin

  data_out <= data_out_3 & data_out_2 & data_out_1 & data_out_0;

  data_out_0 <= memory(to_integer(unsigned(address))) when read_byte = '1' and read_enable = '1' else
                (others => '0');

  data_out_1 <= memory(to_integer(unsigned(address) + 1)) when read_half_word = '1' and read_enable = '1' else
                (others => '0');

  data_out_2 <= memory(to_integer(unsigned(address) + 2)) when read_word = '1' and read_enable = '1' else
                (others => '0');

  data_out_3 <= memory(to_integer(unsigned(address) + 3)) when read_word = '1' and read_enable = '1' else
                (others => '0');

  flash_data : process is

    file     mem_file  : text open read_mode is "data.hex";
    variable line      : line;
    variable mem_value : std_logic_vector(7 downto 0);

  begin

    for i in memory'range loop

      if (not endfile(mem_file)) then
        readline(mem_file, line);
        hread(line, mem_value);
        memory(i) <= mem_value;
      else
        memory(i) <= (others => '0');
      end if;

    end loop;

    wait;

  end process flash_data;

  write_reset : process (clk, reset) is
  begin

    if (reset = '1') then
      memory <= (others => (others => '0'));
    elsif (rising_edge(clk) and write_enable = '1') then
      if (write_byte = '1') then
        memory(to_integer(unsigned(address))) <= data_in(7 downto 0);
      end if;

      if (write_half_word = '1') then
        memory(to_integer(unsigned(address) + 1)) <= data_in(15 downto 8);
      end if;

      if (write_word = '1') then
        memory(to_integer(unsigned(address) + 2)) <= data_in(23 downto 16);
        memory(to_integer(unsigned(address) + 3)) <= data_in(31 downto 24);
      end if;
    end if;

  end process write_reset;

end architecture rtl;
