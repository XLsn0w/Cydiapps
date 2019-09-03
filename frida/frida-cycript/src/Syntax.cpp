/* Cycript - The Truly Universal Scripting Language
 * Copyright (C) 2009-2016  Jay Freeman (saurik)
*/

/* GNU Affero General Public License, Version 3 {{{ */
/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.

 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

#include <cmath>
#include <sstream>

#include "Syntax.hpp"

// XXX: this implementation will break if value[size] is a digit
double CYCastDouble(const char *value, size_t size) {
    char *end;
    double number(strtod(value, &end));
    if (end != value + size)
        return NAN;
    return number;
}

double CYCastDouble(const char *value) {
    return CYCastDouble(value, strlen(value));
}

double CYCastDouble(CYUTF8String value) {
    return CYCastDouble(value.data, value.size);
}

CYRange DigitRange_    (0x3ff000000000000LLU, 0x000000000000000LLU); // 0-9
CYRange WordStartRange_(0x000001000000000LLU, 0x7fffffe87fffffeLLU); // A-Za-z_$
CYRange WordEndRange_  (0x3ff001000000000LLU, 0x7fffffe87fffffeLLU); // A-Za-z_$0-9

#ifdef _WIN32

void *CYPoolFile(CYPool &pool, const char *path, size_t *psize) {
    return nullptr;
}

#else

// XXX: this really should not be here ... :/

#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "String.hpp"

struct CYFile {
    void *data_;
    size_t size_;

    CYFile(void *data, size_t size) :
        data_(data),
        size_(size)
    {
    }
};

static void CYFileExit(void *data) {
    CYFile *file(reinterpret_cast<CYFile *>(data));
    _syscall(munmap(file->data_, file->size_));
}

void *CYPoolFile(CYPool &pool, const char *path, size_t *psize) {
    int fd(_syscall_(open(path, O_RDONLY), 1, ENOENT));
    if (fd == -1)
        return NULL;

    struct stat stat;
    _syscall(fstat(fd, &stat));
    size_t size(stat.st_size);

    *psize = size;

    void *base;
    if (size == 0)
        base = pool.strndup("", 0);
    else {
        _syscall(base = mmap(NULL, size, PROT_READ, MAP_SHARED, fd, 0));

        CYFile *file(new (pool) CYFile(base, size));
        pool.atexit(&CYFileExit, file);
    }

    _syscall(close(fd));
    return base;
}

#endif

CYUTF8String CYPoolFileUTF8String(CYPool &pool, const char *path) {
    CYUTF8String data;
    data.data = reinterpret_cast<char *>(CYPoolFile(pool, path, &data.size));
    return data;
}
