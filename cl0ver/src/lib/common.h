#ifndef COMMON_H
#define COMMON_H

#include <math.h>               // floor, log10
#include <stdbool.h>            // bool
#include <stdint.h>             // uint64_t
#include <stdio.h>              // FILE, fprintf
#include <stdlib.h>             // exit

#include <mach/mach_time.h>     // mach_absolute_time

#include <mach-o/loader.h>      // MH_MAGIC[_64], mach_header[_64], segment_command[_64], section[_64], load_command

#include "try.h"

#ifdef __OBJC__

#   import <Foundation/Foundation.h>

#   define LOG(str, args...) \
    do \
    { \
        if(logfile == NULL) \
            NSLog(@str, ##args); \
        else \
            fprintf(logfile, str, ##args); \
    } while(0)

#else

#   include <syslog.h>

#   define LOG(str, args...) \
    do \
    { \
        if(logfile == NULL) \
            syslog(LOG_WARNING, str, ##args); \
        else \
            fprintf(logfile, str, ##args); \
    } while(0)

#endif // __OBJC__

extern bool verbose;

extern FILE *logfile;

void log_init(const char *file);

void log_release(void);

void sanity(void);

#define ASSERT(expr) \
do \
{ \
    if(!(expr)) \
    { \
        THROW("Assertion failed: " #expr ); \
    } \
} while(0)

#define DEBUG(str, args...) \
do \
{ \
    if(verbose) \
        LOG("[*] " str " [%s:%u %s]\n", ##args, __FILE__, __LINE__, __func__); \
} while(0)

#define WARN_AT(file, line, func, str, args...) \
do \
{ \
    LOG("[!] " str " [%s:%u %s]\n", ##args, file, line, func); \
} while(0)

#define WARN(str, args...) \
do \
{ \
    WARN_AT(__FILE__, __LINE__, __func__, str, ##args); \
} while(0)

#define ERROR_AT(file, line, func, str, args...) \
do \
{ \
    WARN_AT(file, line, func, str, ##args); \
    exit(1); \
} while(0)

#define ERROR(str, args...) \
do \
{ \
    ERROR_AT(__FILE__, __LINE__, __func__, str, ##args); \
} while(0)

#define PRINT_BUF(name, buf, buflen) \
do \
{ \
    DEBUG(name ":"); \
    uint32_t max = (buflen) / sizeof(*(buf)), \
             digits = (uint32_t)floor(log10(max - 1)) + 1; \
    for(uint32_t i = 0; i < max; ++i) \
    { \
        DEBUG( #buf "[%*i]: 0x%0*llx", digits, i, (int)(2 * sizeof(*(buf))), (uint64_t)(buf)[i]); \
    } \
} while(0)

uint64_t nanoseconds_to_mach_time(uint64_t ns);

#define TIMER_START(timer) \
uint64_t timer = mach_absolute_time();

#define TIMER_SLEEP_UNTIL(timer, ns) \
do \
{ \
    mach_wait_until(timer + nanoseconds_to_mach_time(ns)); \
} while(0)

#ifdef __LP64__
#   define ADDR "0x%016llx"
#   define ADDR_IN "%llx"
    typedef uint64_t addr_t;
#   define MACH_MAGIC MH_MAGIC_64
    typedef struct mach_header_64 mach_hdr_t;
    typedef struct segment_command_64 mach_seg_t;
    typedef struct section_64 mach_sec_t;
#else
#   define ADDR "0x%08x"
#   define ADDR_IN "%x"
    typedef uint32_t addr_t;
#   define MACH_MAGIC MH_MAGIC
    typedef struct mach_header mach_hdr_t;
    typedef struct segment_command mach_seg_t;
    typedef struct section mach_sec_t;
#endif

#define SIZE "0x%016lx"
typedef struct load_command mach_cmd_t;
typedef struct
{
    char *buf;
    size_t len;
} file_t;

// sys/param.h defines MIN, avoid redifinition
#ifndef MIN
#   define MIN(x, y) ((x) > (y) ? (y) : (x))
#endif

#endif
