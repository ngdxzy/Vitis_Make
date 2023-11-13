#ifndef __TIMER_HPP__
#define __TIMER_HPP__
#include <unistd.h>                 // sleep
#include <chrono>
#include <string>

typedef struct{
    int m;
    int s;
    int ms;
}human_readable_time;

class timer{
private:
    std::chrono::time_point<std::chrono::system_clock, std::chrono::duration<long long, std::ratio<1, 1000000000>>> last_time_point;
public:
    timer();
    long tick();
    long tick_and_reset();
    void reset();
    human_readable_time convert(long int);
};

#endif
