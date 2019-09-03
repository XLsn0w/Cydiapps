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

#ifndef CYCRIPT_STRING_HPP
#define CYCRIPT_STRING_HPP

#include <iostream>
#include <string>

#include "Pooling.hpp"

struct CYUTF8String {
    const char *data;
    size_t size;

    CYUTF8String() :
        data(NULL),
        size(0)
    {
    }

    CYUTF8String(const char *data) :
        data(data),
        size(strlen(data))
    {
    }

    CYUTF8String(const char *data, size_t size) :
        data(data),
        size(size)
    {
    }

    bool operator ==(const char *value) const {
        size_t length(strlen(data));
        return length == size && memcmp(value, data, length) == 0;
    }

    bool operator !=(const char *value) const {
        size_t length(strlen(data));
        return length != size || memcmp(value, data, length) != 0;
    }

    operator std::string() const {
        return std::string(data, size);
    }
};

static inline std::ostream &operator <<(std::ostream &lhs, const CYUTF8String &rhs) {
    lhs.write(rhs.data, rhs.size);
    return lhs;
}

struct CYUTF16String {
    const uint16_t *data;
    size_t size;

    CYUTF16String(const uint16_t *data, size_t size) :
        data(data),
        size(size)
    {
    }
};

size_t CYGetIndex(const CYUTF8String &value);
bool CYIsKey(CYUTF8String value);

bool CYGetOffset(const char *value, ssize_t &index);

bool CYStartsWith(const CYUTF8String &haystack, const CYUTF8String &needle);

const char *CYPoolCString(CYPool &pool, CYUTF8String utf8);
CYUTF8String CYPoolUTF8String(CYPool &pool, CYUTF8String utf8);
CYUTF8String CYPoolUTF8String(CYPool &pool, const std::string &value);

CYUTF8String CYPoolUTF8String(CYPool &pool, CYUTF16String utf16);
CYUTF16String CYPoolUTF16String(CYPool &pool, CYUTF8String utf8);

#endif/*CYCRIPT_STRING_HPP*/
