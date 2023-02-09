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
    
    ap_uint<512> shift_temp = 0;
    ap_uint<7> frame_counter = 0; // 0-127, required 87

    for (ap_uint<32> data_counter = 0; data_counter < num_of_data; data_counter++){
#pragma HLS pipeline ii=1
        data_t i_temp;
        stream_in >> i_temp;
        shift_temp(511, 128) = shift_temp(383, 0); // shift left by 128 bit
        shift_temp(127, 0) = i_temp; // assign last 128 bit
        ap_uint<2> strb = data_counter(1, 0);
        if ((strb == 3) || (data_counter == (num_of_data - 1))){ // every four data received, the last 2 bit must be 11
            pkt pkt_temp;
            pkt_temp.data = shift_temp;
            for (unsigned char keep_counter = 0; keep_counter < 4; keep_counter++){
#pragma HLS UNROLL
                if(strb >= keep_counter){
                    pkt_temp.keep((keep_counter << 4) | 15, (keep_counter << 4)) = 65535;
                }
                else{
                    pkt_temp.keep((keep_counter << 4) | 15, (keep_counter << 4)) = 0;
                }
            }
            pkt_temp.dest = destination;
            pkt_temp.last = (frame_counter == 87) || (data_counter == (num_of_data - 1)); // one udp_frame or the last data
            stream_out << pkt_temp;
        }
        if (frame_counter == 87){ // one udp frame has 1408 bytes, which is 88 data_t
            frame_counter = 0;
        }
        else{
            frame_counter++;
        }
    }

}
}