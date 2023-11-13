#include "util.hpp"

info_center::info_center(){
    this->system_clock.reset();
    this->bar_counter = 0;
    this->inside_bar = false;
    this->allow_bar = false;
    printf("%-9s | ", "mm:ss: ms");
    printf("%-8s | ", "Type");
    printf("%-9s\n\n", "Message");
}

void info_center::cprint(bool if_print, const char* header, const char* format, ...){
    if (if_print == false){
        return;
    }
    long time_in_us = this->system_clock.tick();
    human_readable_time time_now = this->system_clock.convert(time_in_us);
    va_list args;
    va_start(args, format);
    printf("%02d:%02d:%03d | ", time_now.m, time_now.s, time_now.ms);
    printf("%-8s | ", header);
    vprintf(format, args);
    printf("\n");
    va_end(args);
    this->bar_inc();
}

void info_center::cprint_header(bool if_print, const char* header){
    if (if_print == false){
        return;
    }
    long time_in_us = this->system_clock.tick();
    human_readable_time time_now = this->system_clock.convert(time_in_us);
    printf("%02d:%02d:%03d | ", time_now.m, time_now.s, time_now.ms);
    printf("%-8s | ", header);
}

void info_center::cprint_ident(bool if_print){
    if (if_print == false){
        return;
    }
    printf("%21s| ", "");
}

void info_center::cappend(bool if_print, const char* format, ...){
    if (if_print == false){
        return;
    }
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
}

void info_center::caprint(bool if_print, const char* format, ...){
    if (if_print == false){
        return;
    }
    printf("%21s| ", "");
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    printf("\n");
    va_end(args);
    this->bar_inc();
}

void info_center::print(const char* header, const char* format, ...){
    long time_in_us = this->system_clock.tick();
    human_readable_time time_now = this->system_clock.convert(time_in_us);
    va_list args;
    va_start(args, format);
    printf("%02d:%02d:%03d | ", time_now.m, time_now.s, time_now.ms);
    printf("%-8s | ", header);
    vprintf(format, args);
    printf("\n");
    va_end(args);
    this->bar_inc();
}

void info_center::aprint(const char* format, ...){
    printf("%21s| ", "");
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    printf("\n");
    va_end(args);
    this->bar_inc();
}

void info_center::print_header(const char* header){
    long time_in_us = this->system_clock.tick();
    human_readable_time time_now = this->system_clock.convert(time_in_us);
    printf("%02d:%02d:%03d | ", time_now.m, time_now.s, time_now.ms);
    printf("%-8s | ", header);
}

void info_center::print_ident(){
    printf("%21s| ", "");
    this->bar_inc();
}

void info_center::append(const char* format, ...){
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
}

void info_center::enter(){
    printf("\n");
    this->bar_inc();
}

void info_center::center(bool if_print){
    if (if_print == false){
        return;
    }
    printf("\n");
}

void info_center::bar_begin(){
    if (this->allow_bar){
        this->bar_counter = 0;
        this->inside_bar = true;
        this->bar_time = this->system_clock.tick();
    }
    else{
        this->inside_bar = false;
        this->bar_counter = 0;
        this->bar_time = this->system_clock.tick();
    }
}

void info_center::bar_restart(){
    if (this->inside_bar){
        while(this->bar_counter > 0){
            printf("\033[1A");
            printf("\033[1K");
            this->bar_counter--;
        }
    }
}

void info_center::bar_end(){
    this->bar_counter = 0;
    this->inside_bar = false;
}

void info_center::bar_inc(){
    if (this->inside_bar){
        this->bar_counter++;
    }
}

void info_center::print_process(int current_it, int total_it){
    if (this->inside_bar == false){
        return;
    }

    unsigned long time_now = this->system_clock.tick();

    unsigned long time_passed = time_now - this->bar_time;


    float percentage = (float)current_it / total_it;

    unsigned long time_per_iteration;

    if (current_it > 0){
        time_per_iteration = time_passed / current_it;
    }
    else{
        time_per_iteration = 0;
    }

    unsigned long estimated_time = time_per_iteration * total_it;

    char progress_bar[21];
    for (int i = 0; i < 20; i++){
        if (percentage <= (i * (1.0 / 20.0))){
            progress_bar[i] = '.';
        }
        else{
            progress_bar[i] = '=';
        }
    }
    progress_bar[20] = '\0';
    human_readable_time readable_total_time = this->system_clock.convert(estimated_time - time_passed);

    this->print("Prog.", "  [%s]\t%d/%d  Esti. Left: %d minutes",progress_bar,  current_it, total_it, readable_total_time.m);

}

void info_center::enable_bar(){
    this->allow_bar = true;
    printf("\e[?25l");
}

void info_center::disable_bar(){
    this->allow_bar = false;
    printf("\e[?25h");
}
