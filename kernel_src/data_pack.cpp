#include "ap_axi_sdata.h"
#include "ap_int.h"
#include <ap_fixed.h>
#include "hls_stream.h"

#define DWIDTH 128
#define TDWIDTH 16

typedef ap_uint<DWIDTH> data_t;
typedef ap_axiu<512, 1, 1, TDWIDTH> pkt;


extern "C" {
// Out stream format:
// data: 512 bit void data
// keep: should always be -1
// dest: follow the host, now sure what does it means yet
// 
// Function input:
// N: number of bytes to send
// destination: to dest
void data_pack(unsigned int N, unsigned int destination, hls::stream<data_t>& stream_in, hls::stream<pkt>& stream_out){
#pragma HLS interface s_axilite port=return
#pragma HLS interface s_axilite port=N
#pragma HLS interface s_axilite port=destination

    unsigned int num_of_data = N >> 4; // 128bit -> 2 ^ 4 Bytes, num_of_data should be N >> 4; Now, assuming that N is a multiple of 16 bytes
    unsigned int num_of_pkt =  N >> 6; // 512bit -> 2 ^ 6 Bytes, num_of_pkts should be N >> 6;
    if ((N & 0x3f) != 0){ // if N is not a multiple of 64, the the last 6 bits won't be 0; in this case, there is one more packet
        num_of_pkt = num_of_pkt + 1;
    }
    const unsigned char data_per_pkt = 4; // 4 data makes one pkt

    ap_uint<5> frame_counter = 0; // counts for UDP frame, one frame is 1408 Bytes, 1408/64 = 22 pkts;

    for (unsigned int pkt_counter = 0; pkt_counter < num_of_pkt; pkt_counter++){
#pragma HLS PIPELINE II = 4
        ap_uint<512> data_temp;
        pkt pkt_temp;
        for (unsigned int data_counter = 0; data_counter < data_per_pkt; data_counter++){
#pragma HLS PIPELINE II = 1
            data_t i_temp;
            stream_in >> i_temp;
            ap_uint<32> lower_bound = data_counter << 7;
            ap_uint<32> higer_bound = (data_counter << 7) | 127;
            data_temp(higer_bound, lower_bound) = i_temp;
        }
        pkt_temp.data = data_temp;
        pkt_temp.keep = -1;
        pkt_temp.dest = destination;
        pkt_temp.last = (pkt_counter == (num_of_pkt - 1)) || (frame_counter == 21); // last pkt or one frame finished
        stream_out << pkt_temp;
        if (frame_counter == 21){ // counter between 0 -> 21
            frame_counter = 0;
        }
        else{
            frame_counter++;
        }
    }
}
}