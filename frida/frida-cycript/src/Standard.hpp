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

#ifndef CYCRIPT_STANDARD_HPP
#define CYCRIPT_STANDARD_HPP

#define _not(type) \
    ((type) ~ (type) 0)

#define _label__(x) _label ## x
#define _label_(y) _label__(y)
#define _label _label_(__LINE__)

#ifdef _MSC_VER

#define _finline __forceinline

#define _noreturn

#define _visible

#define _sentinel

typedef intptr_t ssize_t;

#else

#define _finline \
    inline __attribute__((__always_inline__))
#define _disused \
    __attribute__((__unused__))

#define _packed \
    __attribute__((__packed__))
#define _noreturn \
    __attribute__((__noreturn__))

#define _visible \
    __attribute__((__visibility__("default")))

#define _sentinel __attribute__((__sentinel__))

#endif

#define _extern \
    extern "C" _visible

#endif/*CYCRIPT_STANDARD_HPP*/
