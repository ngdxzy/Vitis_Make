`timescale 1 ns / 1 ps

module arp_server_hls_deadlock_idx0_monitor ( // for module arp_server_arp_server_inst
    input wire clock,
    input wire reset,
    input wire [3:0] axis_block_sigs,
    input wire [8:0] inst_idle_sigs,
    input wire [4:0] inst_block_sigs,
    output wire [15:0] axis_block_info,
    output wire block
);

// signal declare
reg [15:0] monitor_axis_block_info;
reg monitor_find_block;
wire idx2_block;
wire idx1_block;
wire idx3_block;
wire [4:0] process_idle_vec;
wire [4:0] process_chan_block_vec;
wire [4:0] process_axis_block_vec;
wire df_has_axis_block;
wire all_process_stop;

assign axis_block_info = (monitor_find_block == 1'b1) ? monitor_axis_block_info : 16'h0;
assign block = monitor_find_block;
assign idx2_block = axis_block_sigs[2];
assign idx3_block = axis_block_sigs[3];
assign process_axis_block_vec[0] = 1'b0;
assign process_idle_vec[0] = inst_idle_sigs[0];
assign process_chan_block_vec[0] = inst_block_sigs[0];
assign process_axis_block_vec[1] = idx1_block & (1'b0 | axis_block_sigs[0] | axis_block_sigs[1]);
assign process_idle_vec[1] = inst_idle_sigs[1];
assign process_chan_block_vec[1] = inst_block_sigs[1];
assign process_axis_block_vec[2] = idx2_block & (1'b0 | axis_block_sigs[2]);
assign process_idle_vec[2] = inst_idle_sigs[2];
assign process_chan_block_vec[2] = inst_block_sigs[2];
assign process_axis_block_vec[3] = idx3_block & (1'b0 | axis_block_sigs[3]);
assign process_idle_vec[3] = inst_idle_sigs[3];
assign process_chan_block_vec[3] = inst_block_sigs[3];
assign process_axis_block_vec[4] = 1'b0;
assign process_idle_vec[4] = inst_idle_sigs[4];
assign process_chan_block_vec[4] = inst_block_sigs[4];
assign df_has_axis_block = |{process_axis_block_vec};
assign all_process_stop = (process_idle_vec[0] | process_chan_block_vec[0] | process_axis_block_vec[0]) & (process_idle_vec[1] | process_chan_block_vec[1] | process_axis_block_vec[1]) & (process_idle_vec[2] | process_chan_block_vec[2] | process_axis_block_vec[2]) & (process_idle_vec[3] | process_chan_block_vec[3] | process_axis_block_vec[3]) & (process_idle_vec[4] | process_chan_block_vec[4] | process_axis_block_vec[4]);

always @(posedge clock) begin
    if (reset == 1'b1)
        monitor_find_block <= 1'b0;
    else if (df_has_axis_block == 1'b1 && all_process_stop == 1'b1)
        monitor_find_block <= 1'b1;
    else
        monitor_find_block <= 1'b0;
end

always @(posedge clock) begin
    if (reset == 1'b1)
        monitor_axis_block_info[3:0] <= 4'h0;
    else if (axis_block_sigs[2])
        monitor_axis_block_info[3:0] <= ~(4'h1 << 0);
    else
        monitor_axis_block_info[3:0] <= 4'h0;
end
always @(posedge clock) begin
    if (reset == 1'b1)
        monitor_axis_block_info[7:4] <= 4'h0;
    else if (axis_block_sigs[0])
        monitor_axis_block_info[7:4] <= ~(4'h1 << 1);
    else
        monitor_axis_block_info[7:4] <= 4'h0;
end
always @(posedge clock) begin
    if (reset == 1'b1)
        monitor_axis_block_info[11:8] <= 4'h0;
    else if (axis_block_sigs[3])
        monitor_axis_block_info[11:8] <= ~(4'h1 << 2);
    else
        monitor_axis_block_info[11:8] <= 4'h0;
end
always @(posedge clock) begin
    if (reset == 1'b1)
        monitor_axis_block_info[15:12] <= 4'h0;
    else if (axis_block_sigs[1])
        monitor_axis_block_info[15:12] <= ~(4'h1 << 3);
    else
        monitor_axis_block_info[15:12] <= 4'h0;
end

// instant sub module
 arp_server_hls_deadlock_idx1_monitor arp_server_hls_deadlock_idx1_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx1_block)
);

endmodule
