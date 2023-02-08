-- ==============================================================
-- RTL generated by Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2021.1 (64-bit)
-- Version: 2021.1
-- Copyright (C) Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ethernet_header_inserter is
port (
    dataIn_TDATA : IN STD_LOGIC_VECTOR (511 downto 0);
    dataIn_TKEEP : IN STD_LOGIC_VECTOR (63 downto 0);
    dataIn_TSTRB : IN STD_LOGIC_VECTOR (63 downto 0);
    dataIn_TLAST : IN STD_LOGIC_VECTOR (0 downto 0);
    dataOut_TDATA : OUT STD_LOGIC_VECTOR (511 downto 0);
    dataOut_TKEEP : OUT STD_LOGIC_VECTOR (63 downto 0);
    dataOut_TSTRB : OUT STD_LOGIC_VECTOR (63 downto 0);
    dataOut_TLAST : OUT STD_LOGIC_VECTOR (0 downto 0);
    arpTableReplay_V_TDATA : IN STD_LOGIC_VECTOR (127 downto 0);
    arpTableRequest_V_TDATA : OUT STD_LOGIC_VECTOR (31 downto 0);
    myMacAddress : IN STD_LOGIC_VECTOR (47 downto 0);
    regSubNetMask : IN STD_LOGIC_VECTOR (31 downto 0);
    regDefaultGateway : IN STD_LOGIC_VECTOR (31 downto 0);
    ap_clk : IN STD_LOGIC;
    ap_rst_n : IN STD_LOGIC;
    dataIn_TVALID : IN STD_LOGIC;
    dataIn_TREADY : OUT STD_LOGIC;
    arpTableRequest_V_TVALID : OUT STD_LOGIC;
    arpTableRequest_V_TREADY : IN STD_LOGIC;
    arpTableReplay_V_TVALID : IN STD_LOGIC;
    arpTableReplay_V_TREADY : OUT STD_LOGIC;
    dataOut_TVALID : OUT STD_LOGIC;
    dataOut_TREADY : IN STD_LOGIC );
end;


architecture behav of ethernet_header_inserter is 
    attribute CORE_GENERATION_INFO : STRING;
    attribute CORE_GENERATION_INFO of behav : architecture is
    "ethernet_header_inserter_ethernet_header_inserter,hls_ip_2021_1,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xcu280-fsvh2892-2L-e,HLS_INPUT_CLOCK=3.100000,HLS_INPUT_ARCH=dataflow,HLS_SYN_CLOCK=2.815938,HLS_SYN_LAT=9,HLS_SYN_TPT=1,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=13960,HLS_SYN_LUT=7480,HLS_VERSION=2021_1}";
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';

    signal ap_rst_n_inv : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_ap_start : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_ap_done : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_ap_continue : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_ap_idle : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_ap_ready : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_ip_header_out_din : STD_LOGIC_VECTOR (1023 downto 0);
    signal broadcaster_and_mac_request_U0_ip_header_out_write : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_no_ip_header_out_din : STD_LOGIC_VECTOR (1023 downto 0);
    signal broadcaster_and_mac_request_U0_no_ip_header_out_write : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_start_out : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_start_write : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_dataIn_TREADY : STD_LOGIC;
    signal broadcaster_and_mac_request_U0_arpTableRequest_V_TDATA : STD_LOGIC_VECTOR (31 downto 0);
    signal broadcaster_and_mac_request_U0_arpTableRequest_V_TVALID : STD_LOGIC;
    signal compute_and_insert_ip_checksum_U0_ap_start : STD_LOGIC;
    signal compute_and_insert_ip_checksum_U0_ap_done : STD_LOGIC;
    signal compute_and_insert_ip_checksum_U0_ap_continue : STD_LOGIC;
    signal compute_and_insert_ip_checksum_U0_ap_idle : STD_LOGIC;
    signal compute_and_insert_ip_checksum_U0_ap_ready : STD_LOGIC;
    signal compute_and_insert_ip_checksum_U0_ip_header_out_read : STD_LOGIC;
    signal compute_and_insert_ip_checksum_U0_ip_header_checksum_din : STD_LOGIC_VECTOR (1023 downto 0);
    signal compute_and_insert_ip_checksum_U0_ip_header_checksum_write : STD_LOGIC;
    signal handle_output_U0_ap_start : STD_LOGIC;
    signal handle_output_U0_ap_done : STD_LOGIC;
    signal handle_output_U0_ap_continue : STD_LOGIC;
    signal handle_output_U0_ap_idle : STD_LOGIC;
    signal handle_output_U0_ap_ready : STD_LOGIC;
    signal handle_output_U0_no_ip_header_out_read : STD_LOGIC;
    signal handle_output_U0_ip_header_checksum_read : STD_LOGIC;
    signal handle_output_U0_arpTableReplay_V_TREADY : STD_LOGIC;
    signal handle_output_U0_dataOut_TDATA : STD_LOGIC_VECTOR (511 downto 0);
    signal handle_output_U0_dataOut_TVALID : STD_LOGIC;
    signal handle_output_U0_dataOut_TKEEP : STD_LOGIC_VECTOR (63 downto 0);
    signal handle_output_U0_dataOut_TSTRB : STD_LOGIC_VECTOR (63 downto 0);
    signal handle_output_U0_dataOut_TLAST : STD_LOGIC_VECTOR (0 downto 0);
    signal ip_header_out_full_n : STD_LOGIC;
    signal ip_header_out_dout : STD_LOGIC_VECTOR (1023 downto 0);
    signal ip_header_out_empty_n : STD_LOGIC;
    signal no_ip_header_out_full_n : STD_LOGIC;
    signal no_ip_header_out_dout : STD_LOGIC_VECTOR (1023 downto 0);
    signal no_ip_header_out_empty_n : STD_LOGIC;
    signal ip_header_checksum_full_n : STD_LOGIC;
    signal ip_header_checksum_dout : STD_LOGIC_VECTOR (1023 downto 0);
    signal ip_header_checksum_empty_n : STD_LOGIC;
    signal start_for_compute_and_insert_ip_checksum_U0_din : STD_LOGIC_VECTOR (0 downto 0);
    signal start_for_compute_and_insert_ip_checksum_U0_full_n : STD_LOGIC;
    signal start_for_compute_and_insert_ip_checksum_U0_dout : STD_LOGIC_VECTOR (0 downto 0);
    signal start_for_compute_and_insert_ip_checksum_U0_empty_n : STD_LOGIC;

    component ethernet_header_inserter_broadcaster_and_mac_request IS
    port (
        ap_clk : IN STD_LOGIC;
        ap_rst : IN STD_LOGIC;
        ap_start : IN STD_LOGIC;
        start_full_n : IN STD_LOGIC;
        ap_done : OUT STD_LOGIC;
        ap_continue : IN STD_LOGIC;
        ap_idle : OUT STD_LOGIC;
        ap_ready : OUT STD_LOGIC;
        dataIn_TVALID : IN STD_LOGIC;
        arpTableRequest_V_TREADY : IN STD_LOGIC;
        ip_header_out_din : OUT STD_LOGIC_VECTOR (1023 downto 0);
        ip_header_out_full_n : IN STD_LOGIC;
        ip_header_out_write : OUT STD_LOGIC;
        no_ip_header_out_din : OUT STD_LOGIC_VECTOR (1023 downto 0);
        no_ip_header_out_full_n : IN STD_LOGIC;
        no_ip_header_out_write : OUT STD_LOGIC;
        start_out : OUT STD_LOGIC;
        start_write : OUT STD_LOGIC;
        dataIn_TDATA : IN STD_LOGIC_VECTOR (511 downto 0);
        dataIn_TREADY : OUT STD_LOGIC;
        dataIn_TKEEP : IN STD_LOGIC_VECTOR (63 downto 0);
        dataIn_TSTRB : IN STD_LOGIC_VECTOR (63 downto 0);
        dataIn_TLAST : IN STD_LOGIC_VECTOR (0 downto 0);
        arpTableRequest_V_TDATA : OUT STD_LOGIC_VECTOR (31 downto 0);
        arpTableRequest_V_TVALID : OUT STD_LOGIC;
        regSubNetMask : IN STD_LOGIC_VECTOR (31 downto 0);
        regDefaultGateway : IN STD_LOGIC_VECTOR (31 downto 0) );
    end component;


    component ethernet_header_inserter_compute_and_insert_ip_checksum IS
    port (
        ap_clk : IN STD_LOGIC;
        ap_rst : IN STD_LOGIC;
        ap_start : IN STD_LOGIC;
        ap_done : OUT STD_LOGIC;
        ap_continue : IN STD_LOGIC;
        ap_idle : OUT STD_LOGIC;
        ap_ready : OUT STD_LOGIC;
        ip_header_out_dout : IN STD_LOGIC_VECTOR (1023 downto 0);
        ip_header_out_empty_n : IN STD_LOGIC;
        ip_header_out_read : OUT STD_LOGIC;
        ip_header_checksum_din : OUT STD_LOGIC_VECTOR (1023 downto 0);
        ip_header_checksum_full_n : IN STD_LOGIC;
        ip_header_checksum_write : OUT STD_LOGIC );
    end component;


    component ethernet_header_inserter_handle_output IS
    port (
        ap_clk : IN STD_LOGIC;
        ap_rst : IN STD_LOGIC;
        ap_start : IN STD_LOGIC;
        ap_done : OUT STD_LOGIC;
        ap_continue : IN STD_LOGIC;
        ap_idle : OUT STD_LOGIC;
        ap_ready : OUT STD_LOGIC;
        no_ip_header_out_dout : IN STD_LOGIC_VECTOR (1023 downto 0);
        no_ip_header_out_empty_n : IN STD_LOGIC;
        no_ip_header_out_read : OUT STD_LOGIC;
        ip_header_checksum_dout : IN STD_LOGIC_VECTOR (1023 downto 0);
        ip_header_checksum_empty_n : IN STD_LOGIC;
        ip_header_checksum_read : OUT STD_LOGIC;
        arpTableReplay_V_TVALID : IN STD_LOGIC;
        dataOut_TREADY : IN STD_LOGIC;
        arpTableReplay_V_TDATA : IN STD_LOGIC_VECTOR (127 downto 0);
        arpTableReplay_V_TREADY : OUT STD_LOGIC;
        myMacAddress : IN STD_LOGIC_VECTOR (47 downto 0);
        dataOut_TDATA : OUT STD_LOGIC_VECTOR (511 downto 0);
        dataOut_TVALID : OUT STD_LOGIC;
        dataOut_TKEEP : OUT STD_LOGIC_VECTOR (63 downto 0);
        dataOut_TSTRB : OUT STD_LOGIC_VECTOR (63 downto 0);
        dataOut_TLAST : OUT STD_LOGIC_VECTOR (0 downto 0) );
    end component;


    component ethernet_header_inserter_fifo_w1024_d16_A IS
    port (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        if_read_ce : IN STD_LOGIC;
        if_write_ce : IN STD_LOGIC;
        if_din : IN STD_LOGIC_VECTOR (1023 downto 0);
        if_full_n : OUT STD_LOGIC;
        if_write : IN STD_LOGIC;
        if_dout : OUT STD_LOGIC_VECTOR (1023 downto 0);
        if_empty_n : OUT STD_LOGIC;
        if_read : IN STD_LOGIC );
    end component;


    component ethernet_header_inserter_start_for_compute_and_insert_ip_checksum_U0 IS
    port (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        if_read_ce : IN STD_LOGIC;
        if_write_ce : IN STD_LOGIC;
        if_din : IN STD_LOGIC_VECTOR (0 downto 0);
        if_full_n : OUT STD_LOGIC;
        if_write : IN STD_LOGIC;
        if_dout : OUT STD_LOGIC_VECTOR (0 downto 0);
        if_empty_n : OUT STD_LOGIC;
        if_read : IN STD_LOGIC );
    end component;



begin
    broadcaster_and_mac_request_U0 : component ethernet_header_inserter_broadcaster_and_mac_request
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst_n_inv,
        ap_start => broadcaster_and_mac_request_U0_ap_start,
        start_full_n => start_for_compute_and_insert_ip_checksum_U0_full_n,
        ap_done => broadcaster_and_mac_request_U0_ap_done,
        ap_continue => broadcaster_and_mac_request_U0_ap_continue,
        ap_idle => broadcaster_and_mac_request_U0_ap_idle,
        ap_ready => broadcaster_and_mac_request_U0_ap_ready,
        dataIn_TVALID => dataIn_TVALID,
        arpTableRequest_V_TREADY => arpTableRequest_V_TREADY,
        ip_header_out_din => broadcaster_and_mac_request_U0_ip_header_out_din,
        ip_header_out_full_n => ip_header_out_full_n,
        ip_header_out_write => broadcaster_and_mac_request_U0_ip_header_out_write,
        no_ip_header_out_din => broadcaster_and_mac_request_U0_no_ip_header_out_din,
        no_ip_header_out_full_n => no_ip_header_out_full_n,
        no_ip_header_out_write => broadcaster_and_mac_request_U0_no_ip_header_out_write,
        start_out => broadcaster_and_mac_request_U0_start_out,
        start_write => broadcaster_and_mac_request_U0_start_write,
        dataIn_TDATA => dataIn_TDATA,
        dataIn_TREADY => broadcaster_and_mac_request_U0_dataIn_TREADY,
        dataIn_TKEEP => dataIn_TKEEP,
        dataIn_TSTRB => dataIn_TSTRB,
        dataIn_TLAST => dataIn_TLAST,
        arpTableRequest_V_TDATA => broadcaster_and_mac_request_U0_arpTableRequest_V_TDATA,
        arpTableRequest_V_TVALID => broadcaster_and_mac_request_U0_arpTableRequest_V_TVALID,
        regSubNetMask => regSubNetMask,
        regDefaultGateway => regDefaultGateway);

    compute_and_insert_ip_checksum_U0 : component ethernet_header_inserter_compute_and_insert_ip_checksum
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst_n_inv,
        ap_start => compute_and_insert_ip_checksum_U0_ap_start,
        ap_done => compute_and_insert_ip_checksum_U0_ap_done,
        ap_continue => compute_and_insert_ip_checksum_U0_ap_continue,
        ap_idle => compute_and_insert_ip_checksum_U0_ap_idle,
        ap_ready => compute_and_insert_ip_checksum_U0_ap_ready,
        ip_header_out_dout => ip_header_out_dout,
        ip_header_out_empty_n => ip_header_out_empty_n,
        ip_header_out_read => compute_and_insert_ip_checksum_U0_ip_header_out_read,
        ip_header_checksum_din => compute_and_insert_ip_checksum_U0_ip_header_checksum_din,
        ip_header_checksum_full_n => ip_header_checksum_full_n,
        ip_header_checksum_write => compute_and_insert_ip_checksum_U0_ip_header_checksum_write);

    handle_output_U0 : component ethernet_header_inserter_handle_output
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst_n_inv,
        ap_start => handle_output_U0_ap_start,
        ap_done => handle_output_U0_ap_done,
        ap_continue => handle_output_U0_ap_continue,
        ap_idle => handle_output_U0_ap_idle,
        ap_ready => handle_output_U0_ap_ready,
        no_ip_header_out_dout => no_ip_header_out_dout,
        no_ip_header_out_empty_n => no_ip_header_out_empty_n,
        no_ip_header_out_read => handle_output_U0_no_ip_header_out_read,
        ip_header_checksum_dout => ip_header_checksum_dout,
        ip_header_checksum_empty_n => ip_header_checksum_empty_n,
        ip_header_checksum_read => handle_output_U0_ip_header_checksum_read,
        arpTableReplay_V_TVALID => arpTableReplay_V_TVALID,
        dataOut_TREADY => dataOut_TREADY,
        arpTableReplay_V_TDATA => arpTableReplay_V_TDATA,
        arpTableReplay_V_TREADY => handle_output_U0_arpTableReplay_V_TREADY,
        myMacAddress => myMacAddress,
        dataOut_TDATA => handle_output_U0_dataOut_TDATA,
        dataOut_TVALID => handle_output_U0_dataOut_TVALID,
        dataOut_TKEEP => handle_output_U0_dataOut_TKEEP,
        dataOut_TSTRB => handle_output_U0_dataOut_TSTRB,
        dataOut_TLAST => handle_output_U0_dataOut_TLAST);

    ip_header_out_U : component ethernet_header_inserter_fifo_w1024_d16_A
    port map (
        clk => ap_clk,
        reset => ap_rst_n_inv,
        if_read_ce => ap_const_logic_1,
        if_write_ce => ap_const_logic_1,
        if_din => broadcaster_and_mac_request_U0_ip_header_out_din,
        if_full_n => ip_header_out_full_n,
        if_write => broadcaster_and_mac_request_U0_ip_header_out_write,
        if_dout => ip_header_out_dout,
        if_empty_n => ip_header_out_empty_n,
        if_read => compute_and_insert_ip_checksum_U0_ip_header_out_read);

    no_ip_header_out_U : component ethernet_header_inserter_fifo_w1024_d16_A
    port map (
        clk => ap_clk,
        reset => ap_rst_n_inv,
        if_read_ce => ap_const_logic_1,
        if_write_ce => ap_const_logic_1,
        if_din => broadcaster_and_mac_request_U0_no_ip_header_out_din,
        if_full_n => no_ip_header_out_full_n,
        if_write => broadcaster_and_mac_request_U0_no_ip_header_out_write,
        if_dout => no_ip_header_out_dout,
        if_empty_n => no_ip_header_out_empty_n,
        if_read => handle_output_U0_no_ip_header_out_read);

    ip_header_checksum_U : component ethernet_header_inserter_fifo_w1024_d16_A
    port map (
        clk => ap_clk,
        reset => ap_rst_n_inv,
        if_read_ce => ap_const_logic_1,
        if_write_ce => ap_const_logic_1,
        if_din => compute_and_insert_ip_checksum_U0_ip_header_checksum_din,
        if_full_n => ip_header_checksum_full_n,
        if_write => compute_and_insert_ip_checksum_U0_ip_header_checksum_write,
        if_dout => ip_header_checksum_dout,
        if_empty_n => ip_header_checksum_empty_n,
        if_read => handle_output_U0_ip_header_checksum_read);

    start_for_compute_and_insert_ip_checksum_U0_U : component ethernet_header_inserter_start_for_compute_and_insert_ip_checksum_U0
    port map (
        clk => ap_clk,
        reset => ap_rst_n_inv,
        if_read_ce => ap_const_logic_1,
        if_write_ce => ap_const_logic_1,
        if_din => start_for_compute_and_insert_ip_checksum_U0_din,
        if_full_n => start_for_compute_and_insert_ip_checksum_U0_full_n,
        if_write => broadcaster_and_mac_request_U0_start_write,
        if_dout => start_for_compute_and_insert_ip_checksum_U0_dout,
        if_empty_n => start_for_compute_and_insert_ip_checksum_U0_empty_n,
        if_read => compute_and_insert_ip_checksum_U0_ap_ready);





    ap_rst_n_inv_assign_proc : process(ap_rst_n)
    begin
                ap_rst_n_inv <= not(ap_rst_n);
    end process;

    arpTableReplay_V_TREADY <= handle_output_U0_arpTableReplay_V_TREADY;
    arpTableRequest_V_TDATA <= broadcaster_and_mac_request_U0_arpTableRequest_V_TDATA;
    arpTableRequest_V_TVALID <= broadcaster_and_mac_request_U0_arpTableRequest_V_TVALID;
    broadcaster_and_mac_request_U0_ap_continue <= ap_const_logic_1;
    broadcaster_and_mac_request_U0_ap_start <= ap_const_logic_1;
    compute_and_insert_ip_checksum_U0_ap_continue <= ap_const_logic_1;
    compute_and_insert_ip_checksum_U0_ap_start <= start_for_compute_and_insert_ip_checksum_U0_empty_n;
    dataIn_TREADY <= broadcaster_and_mac_request_U0_dataIn_TREADY;
    dataOut_TDATA <= handle_output_U0_dataOut_TDATA;
    dataOut_TKEEP <= handle_output_U0_dataOut_TKEEP;
    dataOut_TLAST <= handle_output_U0_dataOut_TLAST;
    dataOut_TSTRB <= handle_output_U0_dataOut_TSTRB;
    dataOut_TVALID <= handle_output_U0_dataOut_TVALID;
    handle_output_U0_ap_continue <= ap_const_logic_1;
    handle_output_U0_ap_start <= ap_const_logic_1;
    start_for_compute_and_insert_ip_checksum_U0_din <= (0=>ap_const_logic_1, others=>'-');
end behav;