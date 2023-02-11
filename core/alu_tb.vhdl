--! To check if our ALU is working correctly, here are some simple test cases.
--! I don't spend much time on these cases and do only smoke testing here.
--! The reason for this is that compliance tests are much more helpful than these unit tests.
--! So that, I'm making a bet on compliance tests and these are just to check if it works at all.
--! Hence... test cases here are just simple stimuli to do some computational operation.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity alu_tb is
end entity alu_tb;

architecture tb of alu_tb is

  component alu is
    port (
      a      : in    std_logic_vector(31 downto 0);
      b      : in    std_logic_vector(31 downto 0);
      funct3 : in    std_logic_vector(2 downto 0);
      funct7 : in    std_logic_vector(6 downto 0);
      result : out   std_logic_vector(31 downto 0)
    );
  end component;

  for uut: alu use entity work.alu;

  signal a      : std_logic_vector(31 downto 0);
  signal b      : std_logic_vector(31 downto 0);
  signal funct3 : std_logic_vector(2 downto 0);
  signal funct7 : std_logic_vector(6 downto 0);
  signal result : std_logic_vector(31 downto 0);

begin

  -- Unit Under Test is our ALU
  -- Here we map internal signals of this architecture to the signals of ALU
  uut : component alu
    port map (
      a      => a,
      b      => b,
      funct3 => funct3,
      funct7 => funct7,
      result => result
    );

  -- The stimuli process that drives the system and sets inputs to the desired state
  -- In the process I'm asserting the the output state is the desired state
  stimuli : process is

    constant propagation_time : time := 1 ns;

  begin

    -- ADD
    -- 5 + 8 = 13
    a      <= std_logic_vector(to_signed(5, a'length));
    b      <= std_logic_vector(to_signed(8, b'length));
    funct3 <= "000";
    funct7 <= "0000000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(13, result'length))
      report "5 + 8 = 13"
      severity error;

    -- SUB
    -- 17 - 9 = 8
    a      <= std_logic_vector(to_signed(17, a'length));
    b      <= std_logic_vector(to_signed(9, b'length));
    funct3 <= "000";
    funct7 <= "0100000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(8, result'length))
      report "17 - 9 = 8"
      severity error;

    -- SLL
    -- 2 << 1 = 4
    -- 0010 << 1 = 0100 = 4
    a      <= std_logic_vector(to_signed(2, a'length));
    b      <= std_logic_vector(to_signed(1, b'length));
    funct3 <= "001";
    funct7 <= "0000000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(4, result'length))
      report "2 << 1 = 4"
      severity error;

    -- SLT
    -- 5 < 10 = 1
    a      <= std_logic_vector(to_signed(5, a'length));
    b      <= std_logic_vector(to_signed(10, b'length));
    funct3 <= "010";
    funct7 <= "0000000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(1, result'length))
      report "5 < 10 = 1"
      severity error;

    -- SLT
    -- 5 < 1 = 0
    a      <= std_logic_vector(to_signed(5, a'length));
    b      <= std_logic_vector(to_signed(1, b'length));
    funct3 <= "010";
    funct7 <= "0000000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(0, result'length))
      report "5 < 1 = 0"
      severity error;

    -- SLTU
    -- 5 < 10 = 1
    a      <= std_logic_vector(to_signed(5, a'length));
    b      <= std_logic_vector(to_signed(10, b'length));
    funct3 <= "011";
    funct7 <= "0000000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(1, result'length))
      report "5 < 10 = 1"
      severity error;

    -- SLTU
    -- 5 < 1 = 0
    a      <= std_logic_vector(to_signed(5, a'length));
    b      <= std_logic_vector(to_signed(1, b'length));
    funct3 <= "011";
    funct7 <= "0000000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(0, result'length))
      report "5 < 1 = 0"
      severity error;

    -- XOR
    -- 2 ^ 4 = 6
    -- 0010 ^ 0100 = 0110 = 6
    a      <= std_logic_vector(to_signed(2, a'length));
    b      <= std_logic_vector(to_signed(4, b'length));
    funct3 <= "100";
    funct7 <= "0000000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(6, result'length))
      report "2 ^ 4 = 6"
      severity error;

    -- SRL
    -- 4 >> 1 = 2
    -- 0100 >> 1 = 0010 = 2
    a      <= std_logic_vector(to_signed(4, a'length));
    b      <= std_logic_vector(to_signed(1, b'length));
    funct3 <= "101";
    funct7 <= "0000000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(2, result'length))
      report "4 >> 1 = 2"
      severity error;

    -- SRA
    -- -4 >>> 1 = -2
    -- 1100 >>> 1 = 1110 = -2
    a      <= std_logic_vector(to_signed(-4, a'length));
    b      <= std_logic_vector(to_signed(1, b'length));
    funct3 <= "101";
    funct7 <= "0100000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(-2, result'length))
      report "-4 >>> 1 = -2"
      severity error;

    -- OR
    -- 4 | 3 = 7
    -- 0100 | 0011 = 0111 = 7
    a      <= std_logic_vector(to_signed(4, a'length));
    b      <= std_logic_vector(to_signed(3, b'length));
    funct3 <= "110";
    funct7 <= "0000000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(7, result'length))
      report "4 | 3 = 7"
      severity error;

    -- AND
    -- 4 & 3 = 0
    -- 0100 & 0011 = 0000 = 0
    a      <= std_logic_vector(to_signed(4, a'length));
    b      <= std_logic_vector(to_signed(3, b'length));
    funct3 <= "111";
    funct7 <= "0000000";
    wait for propagation_time;
    assert result = std_logic_vector(to_signed(0, result'length))
      report "4 & 3 = 0"
      severity error;

    -- Wait for another period to make waveforms easy to read at the end
    wait for propagation_time;

    -- Notify that test bench has finished
    assert false
      report "test bench for ALU is done"
      severity note;

    wait;

  end process stimuli;

end architecture tb;
