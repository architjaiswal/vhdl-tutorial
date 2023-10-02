library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd is
    generic (
        WIDTH : positive := 16);
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        go     : in  std_logic;
        done   : out std_logic;
        x      : in  std_logic_vector(WIDTH-1 downto 0);
        y      : in  std_logic_vector(WIDTH-1 downto 0);
        output : out std_logic_vector(WIDTH-1 downto 0));
end gcd;

architecture FSMD of gcd is
	type STATE_TYPE is (WAIT_FOR_GO, INIT, LOOP_COND, IF_COND,
						IF_BODY, ELSE_BODY, S_DONE);
	signal state : STATE_TYPE;
	
	signal x_reg, y_reg : unsigned(x'range);
	
begin  -- FSMD
	
	process(clk, rst)
	begin
		if (rst = '1') then
			state <= WAIT_FOR_GO;
			output <= (others => '0');
			done <= '0';
			x_reg <= (others => '0');
			y_reg <= (others => '0');
		elsif (rising_edge(clk)) then
			case state is
				when WAIT_FOR_GO =>
					if (go = '1') then
						state <= INIT;
						done <= '0';
					end if;
					
				when INIT =>
					x_reg <= unsigned(x);
					y_reg <= unsigned(y);
					state <= LOOP_COND;
				
				when LOOP_COND =>
					if (x_reg = y_reg) then
						state <= S_DONE;
					else
						state <= IF_COND;
					end if;
					
				when IF_COND =>
					if (x_reg < y_reg) then
						state <= IF_BODY;
					else
						state <= ELSE_BODY;
					end if;
					
				when IF_BODY =>
					y_reg <= y_reg - x_reg;
					state <= LOOP_COND;
				
				when ELSE_BODY =>
					x_reg <= x_reg - y_reg;
					state <= LOOP_COND;
					
				when S_DONE =>
					output <= std_logic_vector(x_reg);
					done <= '1';
					if (go = '0') then
						state <= WAIT_FOR_GO;
					end if;
			end case;
		end if;
	end process;
end FSMD;

architecture FSM_D of gcd is

	signal x_sel  : std_logic;
	signal 	y_sel  : std_logic;
	signal 	x_en   : std_logic;
	signal 	y_en   : std_logic;
	signal 	output_en : std_logic;
		
		-- control inputs
	signal 	x_lt_y : std_logic;
	signal 	x_ne_y : std_logic;

begin
	U_CTRL : entity work.ctrl port map (
		clk => clk,
		rst => rst,
		go => go,
		done => done,
		x_sel => x_sel,
		y_sel => y_sel,
		x_en => x_en,
		y_en => y_en,
		output_en => output_en,
		x_lt_y => x_lt_y,
		x_ne_y => x_ne_y);
		
	U_DATAPATH : entity work.datapath 
	generic map (width => width)
	port map (
		clk => clk,
		rst => rst,
		x_sel => x_sel,
		y_sel => y_sel,
		x_en => x_en,
		y_en => y_en,
		output_en => output_en,
		x_lt_y => x_lt_y,
		x_ne_y => x_ne_y,
		x => x,
		y => y,
		output => output);
end FSM_D;





