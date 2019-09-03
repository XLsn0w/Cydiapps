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

#ifndef CYCRIPT_EXCEPTION_HPP
#define CYCRIPT_EXCEPTION_HPP

#include <cstdlib>

// XXX: does _assert really need this?
#include <errno.h>

#include "Standard.hpp"

class CYPool;

struct _visible CYException {
    virtual ~CYException();

    virtual const char *PoolCString(CYPool &pool) const = 0;
};

void CYThrow(const char *format, ...) _noreturn;

#define CYTry \
    try
#define CYCatch_(value, name) \
    catch (const CYException &error) { \
        *exception = error.CastJSValue(context, name); \
        _assert(*exception != NULL); \
        return value; \
    } catch (...) { \
        *exception = CYCastJSValue(context, "catch(...)"); \
        _assert(*exception != NULL); \
        return value; \
    }
#define CYCatch(value) \
    CYCatch_(value, "Error")
#define CYCatchObject() \
    CYCatch(JSObjectMake(context, NULL, NULL))

#define _assert_(mode, test, code, format, ...) do \
    if (!(test)) \
        CYThrow("*** _%s(%s):%s(%u):%s" format, mode, code, __FILE__, __LINE__, __FUNCTION__, ##__VA_ARGS__); \
while (false)

// XXX: fix this: _ is not safe; this is /not/ Menes ;P
#undef _assert
#define _assert(test) \
    _assert_("assert", (test), #test, "")

#define _require(expr) ({ \
    auto _value = (expr); \
    _assert_("require", _value != NULL, #expr, ""); \
_value; })

#define _trace() do { \
    fprintf(stderr, "_trace(%s:%u)\n", __FILE__, __LINE__); \
} while (false)

static _finline bool CYContains(int value, size_t many, const int *okay) {
    for (size_t i(0); i != many; ++i)
        if (value == okay[i])
            return true;
    return false;
}

#define _syscall_(expr, many, ...) ({ \
    __typeof__(expr) _value; \
    do if ((long) (_value = (expr)) != -1) \
        break; \
    else if (CYContains(errno, many, ((const int [many + 1]) {0, ##__VA_ARGS__} + 1))) \
        break; \
    else \
        _assert_("syscall", errno == EINTR, #expr, " [errno=%d]", errno); \
    while (true); \
    _value; \
})

#define _syscall(expr) \
    _syscall_(expr, 0)

#define _sqlcall(expr) ({ \
    auto _value = (expr); \
    _assert_("sqlcall", _value == 0 || _value >= 100 && _value < 200, #expr, " %u:%s", _value, sqlite3_errmsg(database_)); \
_value; })

#endif/*CYCRIPT_ERROR_HPP*/
