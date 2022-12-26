library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

use std.env.stop;

entity Geterodine_module_tester is
    port (
         Clk => out std_logic;
        nRst => out std_logic;
        ISig_In => out std_logic_vector(9 downto 0);
        QSig_In => out std_logic_vector(9 downto 0);
        ReceiveDataMode => out std_logic;
        DataStrobe => out std_logic;
        FS_IncrDecr => out std_logic_vector(1 downto 0);
    );
end entity Geterodine_module_tester;

architecture a_Geterodine_module_tester of Geterodine_module is
    signal Clk_r: std_logic := '0';
  

    procedure skiptime_Dataflow(time_count: in integer) is
    begin
        count_time: for k in 0 to time_count-1 loop
            wait until falling_edge(Clk_r); 
            wait for 200 ps; --need to wait for signal stability, value depends on the Clk frequency. 
                        --For example, for Clk period = 100 ns (10 MHz) it's ok to wait for 200 ps.
        end loop count_time ;
    end;
begin
    Clk <= Clk_r;
    
    
    Clk_r <= not Clk_r after 20 ns;
    tester_process: process
    begin
        ISig_In <= "0000000000";
        Qsig_In <= "0000000000";
        ReceiveDataMode <= '1';
        nRst <= '0';
        DataStrobe <= '1';
        FS_IncrDecr <= "10";

        skiptime_Dataflow(1);

        nRst <= '1';
        
        for k in 1023 downto 1023-6 loop
            skiptime_Dataflow(1);
            ISig_In <= conv_std_logic_vector(k, ADC_SigIn'length);
            Qsig_In <= conv_std_logic_vector(k, ADC_SigIn'length);
        end loop;
            
        ReceiveDataMode <= '0';
        Qsig_In <= "0000000000";
        for k in 1023 downto 1023-3 loop
            skiptime_ADC(1);
            ADC_SigIn <= conv_std_logic_vector(k, ADC_SigIn'length);
        end loop;
        nRst <= '0';
        ReceiveDataMode <= '1';
        nRst <= '1';

        for k in 1023 downto 1023-6 loop
            skiptime_Dataflow(1);
            ISig_In <= conv_std_logic_vector(k, ADC_SigIn'length);
            Qsig_In <= conv_std_logic_vector(k, ADC_SigIn'length);
        end loop;
            
        ReceiveDataMode <= '0';
        Qsig_In <= "0000000000";
        for k in 1023 downto 1023-3 loop
           ISig_In <= conv_std_logic_vector(k, ADC_SigIn'length);
        end loop;
            
        stop;
    end process;
end architecture;