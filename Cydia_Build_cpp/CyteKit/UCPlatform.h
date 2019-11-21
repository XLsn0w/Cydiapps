/* Cydia - iPhone UIKit Front-End for Debian APT
 * Copyright (C) 2008-2015  Jay Freeman (saurik)
*/

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydia is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydia.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

#ifndef CyteKit_UCPlatform_H
#define CyteKit_UCPlatform_H

#define __STDC_LIMIT_MACROS
#include <stdint.h>

#include <objc/objc.h>

#include <sys/time.h>
#include <time.h>

#define _forever \
    for (;;)

extern struct timeval _ltv;
extern bool _itv;

#define _trace() do { \
    struct timeval _ctv; \
    gettimeofday(&_ctv, NULL); \
    if (!_itv) { \
        _itv = true; \
        _ltv = _ctv; \
    } \
    fprintf(stderr, "%lu.%.6u[%f]:_trace()@%s:%u[%s]\n", \
        _ctv.tv_sec, _ctv.tv_usec, \
        (_ctv.tv_sec - _ltv.tv_sec) + (_ctv.tv_usec - _ltv.tv_usec) / 1000000.0, \
        __FILE__, __LINE__, __FUNCTION__\
    ); \
    _ltv = _ctv; \
} while (false)

#define _assert(test) do \
    if (!(test)) { \
        fprintf(stderr, "_assert(%d:%s)@%s:%u[%s]\n", errno, #test, __FILE__, __LINE__, __FUNCTION__); \
        exit(-1); \
    } \
while (false)

#define _not(type) ((type) ~ (type) 0)

#define _transient

#define _label__(x) _label ## x
#define _label_(y) _label__(y)
#define _label _label_(__LINE__)

#define _packed \
    __attribute__((__packed__))
#define _finline \
    inline __attribute__((__always_inline__))

#define _assume(e) \
    _assert(e)

#define _nodefault \
    default: \
        _assume(false); \
        throw;

#define _likely(expr) \
    __builtin_expect(expr, 1)

#define _unlikely(expr) \
    __builtin_expect(expr, 0)

#endif//CyteKit_UCPlatform_H
