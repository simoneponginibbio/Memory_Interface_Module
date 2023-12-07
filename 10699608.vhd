library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity project_reti_logiche is
    Port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is (START, READ_CHANNEL, READ_ADDRESS, ENABLE_MEMORY, WAITING_STATE, READ_DATA, DONE);
    signal state : state_type := START;
    signal count : integer := 0;
    signal channel : std_logic_vector(1 downto 0) := (others => '0');
    signal address : unsigned(15 downto 0) := (others => '0');
    signal z0, z1, z2, z3 : std_logic_vector(7 downto 0) := (others => '0');
    
begin
    main : process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            o_z0 <= (others => '0');
            o_z1 <= (others => '0');
            o_z2 <= (others => '0');
            o_z3 <= (others => '0');
            o_done <= '0';
            o_mem_we <= '0';
            o_mem_en <= '0';
            count <= 0;
            channel <= (others => '0');
            address <= (others => '0');
            z0 <= (others => '0');
            z1 <= (others => '0');
            z2 <= (others => '0');
            z3 <= (others => '0');
            state <= READ_CHANNEL;
        elsif rising_edge(i_clk) then
            case state is
                when START =>
                    o_z0 <= (others => '0');
                    o_z1 <= (others => '0');
                    o_z2 <= (others => '0');
                    o_z3 <= (others => '0');
                    o_done <= '0';
                    o_mem_we <= '0';
                    o_mem_en <= '0';
                    count <= 0;
                    channel <= (others => '0');
                    address <= (others => '0');
                    state <= READ_CHANNEL;
                when READ_CHANNEL => 
                    if i_start = '1' then
                        channel(1 - count) <= i_w;
                        if count = 1 then
                            state <= READ_ADDRESS;
                        else
                            count <= count + 1;
                        end if;
                    end if;
                when READ_ADDRESS =>
                    if i_start = '1' then
                        address <= shift_left(address, 1);
                        address(0) <= i_w;
                    else
                        state <= ENABLE_MEMORY;
                    end if;
                when ENABLE_MEMORY =>
                    o_mem_addr <= std_logic_vector(address);
                    o_mem_en <= '1';
                    state <= WAITING_STATE;
                when WAITING_STATE =>
                    state <= READ_DATA;
                when READ_DATA =>
                    case channel is
                        when "00" =>
                            z0 <= i_mem_data;
                        when "01" =>
                            z1 <= i_mem_data;
                        when "10" =>
                            z2 <= i_mem_data;
                        when "11" =>
                            z3 <= i_mem_data;
                        when others =>
                    end case;
                    state <= DONE;
                when DONE =>
                    o_z0 <= z0;
                    o_z1 <= z1;
                    o_z2 <= z2;
                    o_z3 <= z3;
                    o_done <= '1';
                    state <= START;
            end case;
        end if;
    end process;         
end Behavioral;
