`timescale 1 ns / 1 ps

module ethernet_header_inserter_hls_deadlock_idx1_monitor ( // for module ethernet_header_inserter_ethernet_header_inserter_inst.broadcaster_and_mac_request_U0
    input wire clock,
    input wire reset,
    input wire [3:0] axis_block_sigs,
    input wire [5:0] inst_idle_sigs,
    input wire [2:0] inst_block_sigs,
    output wire block
);

// signal declare
reg monitor_find_block;
wire pp_is_axis_block;

assign block = monitor_find_block;
assign pp_is_axis_block = 1'b0 | axis_block_sigs[0] | axis_block_sigs[1];

always @(posedge clock) begin
    if (reset == 1'b1)
        monitor_find_block <= 1'b0;
    else if (pp_is_axis_block == 1'b1)
        monitor_find_block <= 1'b1;
    else
        monitor_find_block <= 1'b0;
end


// instant sub module
endmodule
