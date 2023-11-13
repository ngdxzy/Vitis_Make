#ifndef __UTIL_HPP__
#define __UTIL_HPP__

#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include "timer.hpp"

template<typename T>
inline void read_bin(FILE *fp, T data[], int N = 1){
    fread((void*)(data), sizeof(T), N, fp);
}

template<typename T>
inline T read_bin(FILE *fp){
    T temp;
    fread((void*)(&temp), sizeof(T), 1, fp);
    return temp;
}

template<typename T>
inline void write_bin(FILE *fp, T data[], int N = 1){
    fwrite((void*)data, sizeof(T), N, fp);
}

template<typename T>
inline void write_bin(FILE *fp, T data){
    fwrite((void*)(&data), sizeof(T), 1, fp);
}


class info_center{
    private:
        timer system_clock;
        bool inside_bar;
        bool allow_bar;
        unsigned long bar_time;
    public:
        int bar_counter;
        info_center();
        void cprint(bool if_print, const char* header, const char* format, ...);
        void caprint(bool if_print, const char* format, ...);
        void cprint_header(bool if_print, const char* header);
        void cprint_ident(bool if_print);
        void cappend(bool if_print, const char* format, ...);
        void print(const char* header, const char* format, ...);
        void aprint(const char* format, ...);
        void print_header(const char* header);
        void print_ident();
        void append(const char* format, ...);
        void enter();
        void center(bool);
        void bar_begin();
        void bar_restart();
        void bar_end();
        void bar_inc();
        void print_process(int current_it, int total_it);
        void enable_bar();
        void disable_bar();
};

#endif
