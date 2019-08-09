#ifndef UAF_READ_H
#define UAF_READ_H

#include <stddef.h>             // size_t

#include "io.h"                 // OSString

void uaf_get_bytes(const OSString *fake, char *buf, size_t len);

void uaf_read(const char *addr, char *buf, size_t len);

void uaf_dump_kernel(file_t *file);

#endif
