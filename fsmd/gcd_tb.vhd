library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd_tb is
end gcd_tb;

architecture TB of gcd_tb is

  component gcd
    generic (
      WIDTH  :     positive := 16);
    port (
      clk    : in  std_logic;
      rst    : in  std_logic;
      go     : in  std_logic;
      done   : out std_logic;
      x      : in  std_logic_vector(WIDTH-1 downto 0);
      y      : in  std_logic_vector(WIDTH-1 downto 0);
      output : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  constant WIDTH   : positive := 8;
  constant TIMEOUT : time     := 1 ms;

  signal clkEn  : std_logic := '1';
  signal clk    : std_logic := '0';
  signal rst    : std_logic := '1';
  signal go     : std_logic := '0';
  signal done   : std_logic;
  signal x      : std_logic_vector(WIDTH-1 downto 0);
  signal y      : std_logic_vector(WIDTH-1 downto 0);
  signal output : std_logic_vector(WIDTH-1 downto 0);

begin

  UUT : entity work.gcd(FSM_D)
    generic map (
      WIDTH  => WIDTH)
    port map (
      clk    => clk,
      rst    => rst,
      go     => go,
      done   => done,
      x      => x,
      y      => y,
      output => output);

  clk <= not clk and clkEn after 20 ns;

  process

    function GCD (x, y : integer)
      return std_logic_vector is

      variable tmpX, tmpY : integer;
    begin

      tmpX     := x;
      tmpY     := y;
      while (tmpX /= tmpY) loop
        if tmpX < tmpY then
          tmpY := tmpY-tmpX;
        else
          tmpX := tmpX-tmpY;
        end if;
      end loop;

      return std_logic_vector(to_unsigned(tmpX, WIDTH));

    end GCD;

    variable errors  : integer := 0;
    variable percent : integer := 0;
    variable result  : std_logic_vector(WIDTH-1 downto 0);

  begin

    clkEn <= '1';
    rst   <= '1';
    go    <= '0';
    x     <= std_logic_vector(to_unsigned(0, WIDTH));
    y     <= std_logic_vector(to_unsigned(0, WIDTH));
    wait for 200 ns;

    rst <= '0';
    for i in 0 to 5 loop
      wait until clk'event and clk = '1';
    end loop;  -- i

    for i in 1 to 2**WIDTH-1 loop

      x <= std_logic_vector(to_unsigned(i, WIDTH));

      for j in 1 to 2**WIDTH-1 loop

        go <= '1';
        y  <= std_logic_vector(to_unsigned(j, WIDTH));
        wait until done = '1' for TIMEOUT;
        assert(done = '1') report "Done never asserted." severity failure;
        result := GCD(i, j);
        assert(output = result) report "Incorrect GCD" severity failure;

        if done = '0' then
          errors := errors + 1;
        elsif output /= result then
          errors := errors + 1;
        end if;

        go <= '0';
        wait until clk'event and clk = '1';

      end loop;
    end loop;

    clkEn <= '0';
    report "DONE!!!!!!" severity note;

    if errors <= 10 then
      percent := 100-errors*10;
    else
      percent := 0;
    end if;

    report "PERCENTAGE = " & integer'image(percent) severity note;
    wait;

  end process;

end TB;

-- configuration TB_CONFIG of gcd_tb is
  -- for TB
    -- for UUT : gcd
      -- use entity work.gcd(FSMD);
    -- end for;
  -- end for;
-- end TB_CONFIG;
