#include <errno.h>              // errno
#include <stdbool.h>            // bool, true
#include <stdio.h>              // FILE, stderr, fopen, fclose
#include <string.h>             // strerror
#include <sys/sysctl.h>         // sysctlbyname
#include <mach/machine.h>       // CPU_TYPE_*
#include <unistd.h>             // getppid

#include <mach/mach_time.h>     // mach_absolute_time, mach_timebase_info

#include "io.h"                 // OSString
#include "try.h"                // THROW

#include "common.h"

bool verbose = true;

FILE *logfile = NULL;

void log_init(const char *file)
{
    logfile = stderr;
    if(getppid() == 1) // GUI mode
    {
        logfile = NULL;
    }
    else if(file != NULL)
    {
        FILE *f = fopen(file, "wb");
        if(f == NULL)
        {
            THROW("Failed to open logfile (%s)", strerror(errno));
        }
        logfile = f;
    }
}

void log_release(void)
{
    if(logfile != NULL && logfile != stderr)
    {
        fclose(logfile);
        log_init(NULL);
    }
}

void sanity(void)
{
#ifdef __LP64__
    ASSERT(sizeof(OSString) == 8 * sizeof(uint32_t));
#else
    ASSERT(sizeof(OSString) == 5 * sizeof(uint32_t));
#endif

    // Make sure that architecture of the binary matches architecture of the OS
    cpu_type_t type;
    size_t size = sizeof(type);
    if(sysctlbyname("hw.cputype", &type, &size, NULL, 0) != 0)
    {
        THROW("sysctl(\"hw.cputype\") failed: %s", strerror(errno));
    }
    switch(type)
    {
#ifdef __LP64__
        case CPU_TYPE_ARM64: break;
        case CPU_TYPE_ARM:
            THROW("We're running an arm64 binary on an armv7 OS? What kind of black magic is this?!");
            break;
#else
        case CPU_TYPE_ARM: break;
        case CPU_TYPE_ARM64:
            THROW("Program architecture does not match OS architecture. Please use the arm64 slice.");
            break;
#endif
        default:
            THROW("We're neither on an armv7 nor arm64 OS. Something's wrong here.");
            break;
    }

    // In case we panic...
    sync();
}

uint64_t nanoseconds_to_mach_time(uint64_t ns)
{
    static struct mach_timebase_info timebase = { .numer = 0, .denom = 0 };
    if(timebase.denom == 0)
    {
        mach_timebase_info(&timebase);
    }
    return ns * timebase.denom / timebase.numer;
}
