#ifndef IO_H
#define IO_H

#include <stddef.h>             // size_t
#include <stdint.h>             // uint32_t

#include <IOKit/IOKitLib.h>     // io_service_t

#include "common.h"             // addr_t

#define MIG_MSG_SIZE 0x1000

enum
{
    kOSSerializeDictionary      = 0x01000000U,
    kOSSerializeArray           = 0x02000000U,
    kOSSerializeSet             = 0x03000000U,
    kOSSerializeNumber          = 0x04000000U,
    kOSSerializeSymbol          = 0x08000000U,
    kOSSerializeString          = 0x09000000U,
    kOSSerializeData            = 0x0a000000U,
    kOSSerializeBoolean         = 0x0b000000U,
    kOSSerializeObject          = 0x0c000000U,

    kOSSerializeTypeMask        = 0x7F000000U,
    kOSSerializeDataMask        = 0x00FFFFFFU,

    kOSSerializeEndCollection   = 0x80000000U,

    kOSSerializeMagic           = 0x000000d3U,
};

enum
{
    kOSStringNoCopy = 0x00000001,
};

typedef const addr_t * vtab_t;

typedef struct
{
    vtab_t       vtab;
    int          retainCount;
    unsigned int flags;
    unsigned int length;
    const char * string;
} OSString;

/* Building blocks */

io_connect_t _io_spawn_client(void *dict, size_t dictlen);

io_iterator_t _io_iterator(void);

io_object_t _io_next(io_iterator_t it);

void _io_get(io_object_t o, const char *key, void *buf, uint32_t *buflen);

void _io_find(const char *key, void *buf, uint32_t *buflen);

void _io_release_client(io_connect_t client);

/* All-in-one routines */

void dict_get_bytes(void *dict, size_t dictlen, const char *key, void *buf, uint32_t *buflen);

void dict_parse(void *dict, size_t dictlen);

#endif
