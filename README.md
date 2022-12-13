# Vitis_Make

This make file use xilinx v++ tool to build hls kernels, link the kernels and run sw/hw emulation. It is required to set correct vitis platform path in the makefile and specify the project name and kernels to build. The makefile provides more freedom and less load.

0. Apply the official y2k bacth if you haven't do that. (https://support.xilinx.com/s/article/76960?language=en_US)
1. The cpp file that contains the kenrel to build must have the same name with the kernel. For example, if the kernel function name is 'func', its source file must be named as 'func.cpp'
2. The path of tools and platform shall be set in the Makefile.
3. The project name must be specified in the Makefile.
4. The kernel targets are deduced with the filename. \<filename\>.cpp will be compiled to \<filename\>.xo.
5. The linker.cfg in kernel_src folder must be edit before building the 'link'. The syntax to write link file (especially [connectivity]) can be found online.[Xilinx --connectivity](https://docs.xilinx.com/r/en-US/ug1393-vitis-application-acceleration/connectivity-Options)
6. Before running the emulation, you must source Xilinx Vitis settings and Xilinx XRT settings. Source (shell run 'source ...') the setup_xrt.sh in the folder may help (you have to specify your path in setup_xrt.sh).
7. You can set the debug mode in debuging_setup.ini. If you set the 'debug_mode' as 'gui', you can enjoy the live waveform. [Reference](https://docs.xilinx.com/r/2021.2-English/ug1393-vitis-application-acceleration/xrt.ini-File)

To run, simply type:

```shell

make <target> -j<threads_allowed> TARGET=<target sw_emu, hw_emu, hw>

```

For example, if you want build kernels with 8 threads in parallel for hardware emulation, run:

```shell

make kernel -j8 TARGET=hw_emu

```

If you have multiple kernels to build, it is suggested to use as many threads as possible. The maximum number should not exceed the physical number of threads of you computer of course.
It is suggested to run 'make kernel' first and check the maximum allowed frequency. Vitis set the frequency to 250MHz, if the maximum allowed frequency of your kernel is less than 250MHz, the routing (TARGET=hw) will fail. The clock frequency can also be set in the Makefile.

# Targets

## all (default target)

Build kernels, link kernels, build host program and copy them to the current folder.

## kernel

Build kernels. The new kernels are saved in the ./build/vitis_hls. The temporay hls projects are also saved there so that they can be opend with GUI and you can check the scheduling and debuging the kernel.

To open the vitis_hls project for each kernel, you can use:
```shell

vitis_hls -p build/vitis_hls/<kernel_name>/<kernel_name>/<kernel_name>

```


## link

Link the kernels. The linker file ./kernel_src/linker.cfg shall be edit beforehead. The xclbin will be generated in ./build/vivado. Build link will trigger build the kernels if the kernels haven't been build before.

To open the vivado project, you can use:
```shell

vivado -p build/vivado/link/vivado/vpl/prj/prj.xpr

```
## host

Just build the host excutable file. It does not depend on any other objects.

## run

Run the emulation (directly on hardware is not supported, it is designed for AWS). It depends on the excutable file and binary container that in the current folder. If the host and link have been build, the files will be copied to the current folder; if not, it triggers all compiling.

## clean

Clean up the project. Be careful.

