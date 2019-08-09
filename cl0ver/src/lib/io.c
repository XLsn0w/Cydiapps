#include <stdint.h>             // uint32_t, uint64_t

#include <mach/kern_return.h>   // kern_return_t, KERN_SUCCESS
#include <mach/mach_error.h>    // mach_error_string
#include <mach/mach_host.h>     // host_get_io_master, mach_port_t
#include <mach/mach_traps.h>    // mach_host_self
#include <mach/message.h>       // mach_msg_type_number_t
#include <mach/port.h>          // MACH_PORT_NULL, MACH_PORT_VALID

#include <IOKit/IOKitLib.h>     // IO*, io_*
#ifndef __LP64__
#   include <IOKit/iokitmig.h>  // io_service_open_extended
#else
// Yes, I'm including a .c file. Sue me.
#   include "iokitUser.c"       // io_service_open_extended
#endif

#include "common.h"             // DEBUG, TIMER_*
#include "try.h"                // THROW, TRY, FINALLY

#include "io.h"

/* Helper functions */

static mach_port_t get_io_master_port(void)
{
    static mach_port_t master = MACH_PORT_NULL;
    if(master == MACH_PORT_NULL)
    {
        DEBUG("Getting IO master port...");
        kern_return_t ret = host_get_io_master(mach_host_self(), &master);
        if(ret != KERN_SUCCESS || !MACH_PORT_VALID(master))
        {
            THROW("Failed to get IO master port (port = 0x%08x, ret = %u: %s)", master, ret, mach_error_string(ret));
        }
    }
    return master;
}

static io_service_t _io_get_service(void)
{
    static io_service_t service = MACH_PORT_NULL;
    if(service == MACH_PORT_NULL)
    {
        DEBUG("Getting IO service handle...");
        service = IOServiceGetMatchingService(get_io_master_port(), IOServiceMatching("AppleMobileFileIntegrity"));
        if(!MACH_PORT_VALID(service))
        {
            THROW("Failed to get IO service handle (port = 0x%08x)", service);
        }
    }
    return service;
}

/* Building blocks */

io_connect_t _io_spawn_client(void *dict, size_t dictlen)
{
    DEBUG("Spawning user client / Parsing dictionary...");
    io_connect_t client = MACH_PORT_NULL;
    kern_return_t err;
    kern_return_t ret = io_service_open_extended(_io_get_service(), mach_task_self(), 0, NDR_record, dict, dictlen, &err, &client);
    if(ret != KERN_SUCCESS || err != KERN_SUCCESS || !MACH_PORT_VALID(client))
    {
        THROW("Failed to parse dictionary (client = 0x%08x, ret = %u: %s, err = %u: %s)", client, ret, mach_error_string(ret), err, mach_error_string(err));
    }
    return client;
}

io_iterator_t _io_iterator(void)
{
    DEBUG("Creating dict iterator...");
    io_iterator_t it = 0;
    kern_return_t ret = IORegistryEntryCreateIterator(_io_get_service(), "IOService", kIORegistryIterateRecursively, &it);
    if(ret != KERN_SUCCESS)
    {
        THROW("Failed to create iterator (ret = %u: %s)", ret, mach_error_string(ret));
    }
    return it;
}

io_object_t _io_next(io_iterator_t it)
{
    DEBUG("Getting next element from iterator...");
    io_object_t o = IOIteratorNext(it);
    if(o == 0)
    {
        THROW("Failed to get next iterator element");
    }
    return o;
}

void _io_get(io_object_t o, const char *key, void *buf, uint32_t *buflen)
{
    DEBUG("Retrieving bytes...");
    kern_return_t ret = IORegistryEntryGetProperty(o, key, buf, buflen);
    if(ret != KERN_SUCCESS)
    {
        THROW("Failed to get bytes (ret = %u: %s)", ret, mach_error_string(ret));
    }
}

void _io_find(const char *key, void *buf, uint32_t *buflen)
{
    io_iterator_t it = _io_iterator();
    TRY
    ({
        io_object_t o;
        bool found = false;
        while(!found && (o = _io_next(it)) != 0)
        {
            if(IORegistryEntryGetProperty(o, key, buf, buflen) == KERN_SUCCESS)
            {
                found = true;
            }
            IOObjectRelease(o);
        }
        if(!found)
        {
            THROW("Failed to find property: %s", key);
        }
    })
    FINALLY
    ({
        IOObjectRelease(it);
    })
}

void _io_release_client(io_connect_t client)
{
    DEBUG("Releasing user client...");
    kern_return_t ret = IOServiceClose(client);
    if(ret != KERN_SUCCESS)
    {
        THROW("Failed to release user client (ret = %u: %s)", ret, mach_error_string(ret));
    }
}

/* All-in-one routines */

void dict_get_bytes(void *dict, size_t dictlen, const char *key, void *buf, uint32_t *buflen)
{
    TIMER_START(timer);
    io_connect_t client = _io_spawn_client(dict, dictlen);
    TRY
    ({
        _io_find(key, buf, buflen);
    })
    FINALLY
    ({
        _io_release_client(client);
    })
    // Async cleanup
    TIMER_SLEEP_UNTIL(timer, 50e6); // 50ms
}

void dict_parse(void *dict, size_t dictlen)
{
    TIMER_START(timer);
    _io_release_client(_io_spawn_client(dict, dictlen));
    // Async cleanup
    TIMER_SLEEP_UNTIL(timer, 50e6); // 50ms
}
