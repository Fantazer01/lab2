library ieee;
use ieee.std_logic_1164.all;

entity GSMRegister is
	port
	(
		clk	: in	std_logic;
		nRst	: in	std_logic;
		
		--Wishbone
		WB_Addr		: in	std_logic_vector( 15 downto 0 );
		WB_DataOut	: out	std_logic_vector( 15 downto 0 );
		WB_DataIn	: in	std_logic_vector( 15 downto 0 );
		WB_WE			: in 	std_logic;
		WB_Sel		: in 	std_logic_vector( 1 downto 0 );
		WB_STB		: in 	std_logic;
		WB_Cyc_0		: in	std_logic;
		WB_Cyc_2		: in	std_logic;
		WB_Ack		: out std_logic;
		WB_CTI		: in	std_logic_vector(2 downto 0);

		PRT_O						: out 	std_logic_vector( 15 downto 0 ); --Ð´Ð°Ð½Ð½ÑÐµ Ð´Ð»Ñ ÐºÐ¾Ð´Ð¸ÑÐ¾Ð²Ð°Ð½Ð¸Ñ Ð¸ Ð¼Ð¾Ð´ÑÐ»ÑÑÐ¸Ð¸
--		Amplitude_OUT			: out 	std_logic_vector( 15 downto 0);
--		StartPhase_OUT			: out 	std_logic_vector( 15 downto 0);
		CarrierFrequency_OUT	: out 	std_logic_vector(31 downto 0);
		SymbolFrequency_OUT	: out 	std_logic_vector( 31 downto 0);
		DataPort_OUT			: out 	std_logic_vector( 15 downto 0);--Ð¸Ð´ÐµÑ Ð² FIFO
		wrreq						: out 	std_logic;
		full : in std_logic
	);
end entity GSMRegister;
architecture Behavior of GSMRegister is
	signal QH_r: std_logic_vector( 7 downto 0 );
	signal QL_r: std_logic_vector( 7 downto 0 );
--	signal Amplitude_r: std_logic_vector( 15 downto 0 );
--	signal Start_Phase_r: std_logic_vector( 15 downto 0 );
	signal WB_DataOut_r: std_logic_vector(15 downto 0);
	signal Carrier_Frequency_r: std_logic_vector( 31 downto 0 );
	signal Symbol_Frequency_r: std_logic_vector( 31 downto 0 );
	signal DataPort_r: std_logic_vector( 15 downto 0 ); -- Ð¿Ð¾Ð¹Ð´ÐµÑ Ð² Ð¤ÐÐ¤Ð
	signal Ack_r: std_logic;
	signal wrreq_r: std_logic;
begin
		
		process(clk,nRst, WB_STB, WB_WE, WB_Cyc_0, WB_Cyc_2)
		begin
			if (nRst = '0') then
				QH_r <= x"00";
				QL_r <= x"00";
--				Amplitude_r <= x"0000";
--				Start_Phase_r <= x"0000";
				Carrier_Frequency_r <= x"00000000";
				Symbol_Frequency_r <= x"00000000";
				DataPort_r <= x"0000";
				wrreq_r <= '0';
				Ack_r <= '0';
				WB_DataOut_r <= "0000000000000000";
			elsif (rising_edge(clk)) then
			
				if ((WB_STB and WB_Cyc_2) = '1') then
					if(Ack_r = '0') then
						if (WB_Addr = x"000C")then
						   if (full = '0') then
						     Ack_r <= '1';
						   end if;
						else
							Ack_r <= '1';
						end if;
					else
						Ack_r <= '0';
					end if;
				elsif ((WB_STB and WB_Cyc_0) = '1') then
					if (Ack_r = '0') then
						Ack_r <= '1';
					else
						Ack_r <= '0';
					end if;
				else
					Ack_r <= '0';
				end if;
				--
				
				if (WB_Cyc_2 = '1' and WB_WE = '1' and WB_STB = '1' and WB_Addr = x"000C") then
					if (full = '0') then
						wrreq_r <= '1';
					else
						wrreq_r <= '0';
					end if;
				else
					wrreq_r <= '0';
				end if;
				
				if (WB_Cyc_0 = '1') then 
					if(WB_WE = '1' and WB_STB = '1') then
						if(WB_Addr = x"0000") then
							if(WB_Sel(1) = '1')then
								QH_r <= WB_DataIn( 15 downto 8 );
							end if;
							if(WB_Sel(0) = '1') then
								QL_r <= WB_DataIn( 7 downto 0 );
							end if;
						end if;
					elsif(WB_WE = '0' and WB_STB = '1') then
						if(WB_Addr = x"0000") then
							WB_DataOut_r( 15 downto 0 ) <= QH_r & QL_r;
						end if;
					end if;
					--
				elsif (WB_Cyc_2 = '1') then
					if(WB_WE = '1' and WB_STB = '1') then
						if(WB_Addr = x"0004") then
							Carrier_Frequency_r( 31 downto 16 ) <= WB_DataIn;
						elsif(WB_Addr = x"0006") then
							Carrier_Frequency_r( 15 downto 0 ) <= WB_DataIn;
						elsif(WB_Addr = x"0008") then
							Symbol_Frequency_r( 31 downto 16 ) <= WB_DataIn;
						elsif(WB_Addr = x"000A") then
							Symbol_Frequency_r( 15 downto 0 ) <= WB_DataIn;
						elsif(WB_Addr = x"000C") then
							if (full = '0')then
								DataPort_r <= WB_DataIn;
							end if;
						end if;
					elsif(WB_WE = '0' and WB_STB = '1') then
						if(WB_Addr = x"0004") then
							WB_DataOut_r <= Carrier_Frequency_r( 31 downto 16 );
						elsif(WB_Addr = x"0006") then
							WB_DataOut_r <= Carrier_Frequency_r( 15 downto 0 );
						elsif(WB_Addr = x"0008") then
							WB_DataOut_r <= Symbol_Frequency_r( 31 downto 16 );
						elsif(WB_Addr = x"000A") then
							WB_DataOut_r <= Symbol_Frequency_r( 15 downto 0 );
						elsif(WB_Addr = x"000C") then
							WB_DataOut_r <= DataPort_r;
						end if;
					end if;
				end if;
			end if;
		end process;
 	PRT_O( 15 downto 0 ) <= QH_r & QL_r;
--	Amplitude_OUT <= Amplitude_r;
--	StartPhase_OUT <= Start_Phase_r;
	CarrierFrequency_OUT <= Carrier_Frequency_r;
	SymbolFrequency_OUT <= Symbol_Frequency_r;
	DataPort_OUT <= DataPort_r;
	wrreq <= wrreq_r;
	WB_Ack <= Ack_r;
	WB_DataOut <= WB_DataOut_r;
end architecture Behavior;
