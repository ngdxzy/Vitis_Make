#include <iostream>
#include <iomanip>
#include <stdio.h>
#include <xrt/xrt_device.h>         // bitstream
#include <xrt/xrt_bo.h>             // buffers
#include <xrt/xrt_kernel.h>         // kernels, runs
#include <experimental/xrt_ip.h>    // IP direct control
#include <unistd.h>                 // sleep
#include <math.h>
#include <time.h>
#include <stdlib.h>
#include "util.hpp"
#include "timer.hpp"

using namespace std::chrono;

info_center info;
bool DEBUG = true;

int main(int argc, char* argv[]){
    int RET;
    
    char* xclbinFilename;


    info.print("Info", "%d arguments got!", argc);

    if (argc < 2){
        printf("Usage: %s <XCLBIN File> \n", argv[0]);
        return EXIT_FAILURE;
    }
    xclbinFilename = argv[1];


    // user logic
    timer clock;


    // Load xclbin 
    unsigned int device_id = 0; // by default
    auto device = xrt::device(device_id);

    info.print("Process", "Connected to device!");
    xrt::uuid overlay_uuid = device.load_xclbin(xclbinFilename);
    info.print("Process", "Loaded Overlay!");
   

    std::cout << "TEST PASSED\n";
    return EXIT_SUCCESS;


}
