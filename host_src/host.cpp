/**
* Copyright (C) 2019-2021 Xilinx, Inc
*
* Licensed under the Apache License, Version 2.0 (the "License"). You may
* not use this file except in compliance with the License. A copy of the
* License is located at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
* License for the specific language governing permissions and limitations
* under the License.
*/

/*
   Shift Register

   This example demonstrates how to perform a shift register operation to
   implement a Finite Impulse Response(FIR) filter.

   NOTE: See the fir.cl file for additional information.
  */
#include "xcl2.hpp"
#include "typedef.hpp"
#include <algorithm>
#include <random>
#include <string>
#include <vector>
#include <stdio.h>
typedef float d_in_type;
typedef float d_out_type;
const int cus = 1;
using std::default_random_engine;
using std::inner_product;
using std::string;
using std::uniform_int_distribution;
using std::vector;

uint64_t get_duration_ns(const cl::Event& event);

int main(int argc, char** argv) {
	int shift_num = 0;
	const int IT = 300;

	FILE* fp;
    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " <XCLBIN File>" << std::endl;
        return EXIT_FAILURE;
    }
    if(argc > 2){
		sscanf(argv[2],"%d",&shift_num);
	}
	if(shift_num % 2 != 0){
		shift_num = shift_num - 1;
		printf("Shift must be even; using %d for simulation!\n",shift_num);
	}
	printf("Start! %d time steps!\n", IT);
    std::string binaryFile = argv[1];
    cl_int err;
    cl::CommandQueue q;
    cl::Context context;
    cl::Program program;

    vector<d_in_type, aligned_allocator<d_in_type> > A(M_num * K * K + K * S * 2);
    vector<d_in_type, aligned_allocator<d_in_type> > x(M);
    vector<d_out_type, aligned_allocator<d_out_type> > y(IT * M);
    vector<unsigned short, aligned_allocator<unsigned short> > sw(IT);
	printf("Opening LLC_M.txt!\n");
    fp = fopen("/home/alfred/Projects/Vitis/spice/terminal_make/host_src/LLC_M.txt","r");
	printf("Opened LLC_M.txt!\n");
    for(int i = 0;i < M_num * K * K + K * S * 2;i++){
    	fscanf(fp,"%f",&A[i]);
	}
    for(int i = 0;i < M;i++){
    	float temp = 0;
    	fscanf(fp,"%f",&temp);
    	x[i] = temp;
    	printf("%f\t",x[i]);
	}
    printf("\n");
    printf("Loaded!\n");
    fclose(fp);
    for(int i = 0;i < IT;i++){
    	if((i % 100) > 50)
    		sw[i] = 1;
    	else
    		sw[i] = 2;
	}


    auto A_size_in_bytes = (M_num * K * K + K * S * 2) * sizeof(d_in_type);
    auto x_size_in_bytes = M * sizeof(d_in_type);
    auto y_size_in_bytes = IT * M * sizeof(d_out_type);
    auto sw_size_in_bytes = IT * sizeof(unsigned short);

    // Initialize OpenCL context and load xclbin binary
    auto devices = xcl::get_xil_devices();

    // read_binary_file() is a utility API which will load the binaryFile
    // and will return the pointer to file buffer.
    auto fileBuf = xcl::read_binary_file(binaryFile);
    cl::Program::Binaries bins{{fileBuf.data(), fileBuf.size()}};
    bool valid_device = false;
    for (unsigned int i = 0; i < devices.size(); i++) {
        auto device = devices[i];
        // Creating Context and Command Queue for selected Device
        OCL_CHECK(err, context = cl::Context(device, nullptr, nullptr, nullptr, &err));
        OCL_CHECK(err, q = cl::CommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE, &err));

        std::cout << "Trying to program device[" << i << "]: " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
        program = cl::Program(context, {device}, bins, nullptr, &err);
        if (err != CL_SUCCESS) {
            std::cout << "Failed to program device[" << i << "] with xclbin file!\n";
        } else {
            std::cout << "Device[" << i << "]: program successful!\n";
            valid_device = true;
            break; // we break because we found a valid device
        }
    }
    if (!valid_device) {
        std::cout << "Failed to program any device found, exit!\n";
        exit(EXIT_FAILURE);
    }
#
    // Allocate Buffer in Global Memory
    OCL_CHECK(err, cl::Buffer A_buffer(context, CL_MEM_USE_HOST_PTR | CL_MEM_READ_ONLY, A_size_in_bytes,
                                            A.data(), &err));
    OCL_CHECK(err, cl::Buffer x_buffer(context, CL_MEM_USE_HOST_PTR | CL_MEM_READ_ONLY, x_size_in_bytes,
                                            x.data(), &err));
    OCL_CHECK(err, cl::Buffer y_buffer(context, CL_MEM_USE_HOST_PTR | CL_MEM_WRITE_ONLY, y_size_in_bytes, y.data(),
                                            &err));
    OCL_CHECK(err, cl::Buffer sw_buffer(context, CL_MEM_USE_HOST_PTR | CL_MEM_WRITE_ONLY, sw_size_in_bytes, sw.data(),
                                            &err));

    // Creating Naive Kernel Object and setting args
    std::vector<cl::Kernel> spice_multi_kernels(cus);
    char kernel_name[64];
    for (int i = 0; i < cus; i++){
    	sprintf(kernel_name,"spice:{spice_%d}", i+1);
    	OCL_CHECK(err, spice_multi_kernels[i] = cl::Kernel(program, kernel_name, &err));
    }

    OCL_CHECK(err, err = spice_multi_kernels[0].setArg(0, y_buffer));
    OCL_CHECK(err, err = spice_multi_kernels[0].setArg(1, A_buffer));
    OCL_CHECK(err, err = spice_multi_kernels[0].setArg(2, x_buffer));
    OCL_CHECK(err, err = spice_multi_kernels[0].setArg(3, sw_buffer));
    OCL_CHECK(err, err = spice_multi_kernels[0].setArg(4, IT));
//    OCL_CHECK(err, err = spice_multi_kernels[1].setArg(0, y_buffer));
//    OCL_CHECK(err, err = spice_multi_kernels[1].setArg(1, A_buffer));
//    OCL_CHECK(err, err = spice_multi_kernels[1].setArg(2, x_buffer));
//    OCL_CHECK(err, err = spice_multi_kernels[1].setArg(3, reload));

    // Copy input data to device global memory
    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({A_buffer, x_buffer, sw_buffer}, 0 /* 0 means from host*/));

    cl::Event event;

    uint64_t multi_time = 0;
	OCL_CHECK(err, err = q.enqueueTask(spice_multi_kernels[0], nullptr, &event));
	OCL_CHECK(err, err = q.enqueueMigrateMemObjects({y_buffer}, CL_MIGRATE_MEM_OBJECT_HOST));
	q.finish();
	multi_time = get_duration_ns(event);
	printf("First fihinsed!\n");
	multi_time = 0;
	OCL_CHECK(err, err = q.enqueueTask(spice_multi_kernels[0], nullptr, &event));
	OCL_CHECK(err, err = q.enqueueMigrateMemObjects({y_buffer}, CL_MIGRATE_MEM_OBJECT_HOST));
	q.finish();
	multi_time = get_duration_ns(event);

	bool correct = 1;
    fp = fopen("/home/alfred/Projects/Vitis/spice/spice/src/res.txt","w");
	for (int i = 0; i < IT; i++){
		for (int j = 0; j < K; j++) {
			fprintf(fp,"%e\t",y[i * K + j]);

		}
		fprintf(fp,"\n");
	}
	fclose(fp);
//	printf("************************\n");
//	OCL_CHECK(err, err = q.enqueueMigrateMemObjects({A_buffer, x_buffer, sw_buffer}, 0 /* 0 means from host*/));
//
//
//		OCL_CHECK(err, err = q.enqueueTask(spice_multi_kernels[0], nullptr, &event));
//		OCL_CHECK(err, err = q.enqueueMigrateMemObjects({y_buffer}, CL_MIGRATE_MEM_OBJECT_HOST));
//		q.finish();
//		multi_time = get_duration_ns(event);
//
//		for (int i = 0; i < IT; i++){
//			for (int j = 0; j < K; j++) {
//				printf("%e\t",y[i * K + j]);
//
//			}
//			printf("\n");
//		}


	if(correct){
		printf("Success! It takes %.2lu ns!\n", multi_time);
	}
	else{
		printf("Result is wrong!\n");
	}


    return EXIT_SUCCESS;
}
uint64_t get_duration_ns(const cl::Event& event) {
    uint64_t nstimestart, nstimeend;
    cl_int err;
    OCL_CHECK(err, err = event.getProfilingInfo<uint64_t>(CL_PROFILING_COMMAND_START, &nstimestart));
    OCL_CHECK(err, err = event.getProfilingInfo<uint64_t>(CL_PROFILING_COMMAND_END, &nstimeend));
    return (nstimeend - nstimestart);
}
