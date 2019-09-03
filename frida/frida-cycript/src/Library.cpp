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

#include "cycript.hpp"

#include <iostream>
#include <set>
#include <map>
#include <sstream>

#include "Code.hpp"
#include "ConvertUTF.h"
#include "Driver.hpp"
#include "Error.hpp"
#include "Execute.hpp"
#include "Pooling.hpp"
#include "String.hpp"
#include "Syntax.hpp"

_visible CYUTF8String CYPoolUTF8String(CYPool &pool, const std::string &value) {
    return {pool.strndup(value.data(), value.size()), value.size()};
}

/* C Strings {{{ */
CYUTF8String CYPoolUTF8String(CYPool &pool, CYUTF16String utf16) {
    // XXX: this is wrong
    size_t size(utf16.size * 5);
    char *temp(new(pool) char[size + 1]);

    const uint16_t *lhs(utf16.data);
    uint8_t *rhs(reinterpret_cast<uint8_t *>(temp));
    _assert(ConvertUTF16toUTF8(&lhs, lhs + utf16.size, &rhs, rhs + size, lenientConversion) == conversionOK);

    *rhs = 0;
    return CYUTF8String(temp, reinterpret_cast<char *>(rhs) - temp);
}

CYUTF16String CYPoolUTF16String(CYPool &pool, CYUTF8String utf8) {
    // XXX: this is wrong
    size_t size(utf8.size * 5);
    uint16_t *temp(new (pool) uint16_t[size + 1]);

    const uint8_t *lhs(reinterpret_cast<const uint8_t *>(utf8.data));
    uint16_t *rhs(temp);
    _assert(ConvertUTF8toUTF16(&lhs, lhs + utf8.size, &rhs, rhs + size, lenientConversion) == conversionOK);

    *rhs = 0;
    return CYUTF16String(temp, rhs - temp);
}
/* }}} */
/* Index Offsets {{{ */
size_t CYGetIndex(const CYUTF8String &value) {
    if (value.data[0] != '0') {
        size_t index(0);
        for (size_t i(0); i != value.size; ++i) {
            if (!DigitRange_[value.data[i]])
                return _not(size_t);
            index *= 10;
            index += value.data[i] - '0';
        }
        return index;
    } else if (value.size == 1)
        return 0;
    else
        return _not(size_t);
}

// XXX: this isn't actually right
bool CYGetOffset(const char *value, ssize_t &index) {
    if (value[0] != '0') {
        char *end;
        index = strtol(value, &end, 10);
        if (value + strlen(value) == end)
            return true;
    } else if (value[1] == '\0') {
        index = 0;
        return true;
    }

    return false;
}
/* }}} */

bool CYIsKey(CYUTF8String value) {
    const char *data(value.data);
    size_t size(value.size);

    if (size == 0)
        return false;

    if (DigitRange_[data[0]]) {
        size_t index(CYGetIndex(value));
        if (index == _not(size_t))
            return false;
    } else {
        if (!WordStartRange_[data[0]])
            return false;
        for (size_t i(1); i != size; ++i)
            if (!WordEndRange_[data[i]])
                return false;
    }

    return true;
}

_visible bool CYStartsWith(const CYUTF8String &haystack, const CYUTF8String &needle) {
    return haystack.size >= needle.size && strncmp(haystack.data, needle.data, needle.size) == 0;
}

CYUTF8String CYPoolCode(CYPool &pool, std::streambuf &stream) {
    CYLocalPool local;
    CYDriver driver(local, stream);

    if (driver.Parse()) {
        if (!driver.errors_.empty())
            CYThrow("%s", driver.errors_.front().message_.c_str());
        CYThrow("syntax error");
    }

    CYOptions options;
    CYContext context(options);
    driver.script_->Replace(context);

    std::stringbuf str;
    CYOutput out(str, options);
    out << *driver.script_;
    return pool.strdup(str.str().c_str());
}

CYUTF8String CYPoolCode(CYPool &pool, CYUTF8String code) {
    CYStream stream(code.data, code.data + code.size);
    return CYPoolCode(pool, stream);
}

CYPool &CYGetGlobalPool() {
    static CYPool pool;
    return pool;
}
