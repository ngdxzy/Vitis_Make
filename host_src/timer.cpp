#include "timer.hpp"

timer::timer(){
    this->last_time_point = std::chrono::high_resolution_clock::now();
}

long timer::tick(){
    auto new_time = std::chrono::high_resolution_clock::now();
    auto time_consumed = std::chrono::duration_cast<std::chrono::microseconds>(new_time - this->last_time_point);
    long time_consumed_in_us = time_consumed.count();
    return time_consumed_in_us;
}

void timer::reset(){
    auto new_time = std::chrono::high_resolution_clock::now();
    this->last_time_point = new_time;
}

long timer::tick_and_reset(){
    auto new_time = std::chrono::high_resolution_clock::now();
    auto time_consumed = std::chrono::duration_cast<std::chrono::microseconds>(new_time - this->last_time_point);
    this->last_time_point = new_time;
    long time_consumed_in_us = time_consumed.count();

    return time_consumed_in_us;
}

human_readable_time timer::convert(long int t_in_us){
    human_readable_time temp;
    temp.ms = int(t_in_us / 1e3);
    temp.s = int(temp.ms / 1e3);
    temp.m = int(temp.s / 60);
    temp.ms %= 1000;
    temp.s %= 60;
    temp.m %= 100;
    return temp;
}
