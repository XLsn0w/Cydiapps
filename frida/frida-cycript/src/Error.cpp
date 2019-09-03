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

#include "Error.hpp"

CYException::~CYException() {
}

const char *CYPoolError::PoolCString(CYPool &pool) const {
    return pool.strdup(message_);
}

CYPoolError::CYPoolError(const CYPoolError &rhs) :
    message_(pool_.strdup(rhs.message_))
{
}

CYPoolError::CYPoolError(const char *message) {
    message_ = pool_.strdup(message);
}

CYPoolError::CYPoolError(const char *format, ...) {
    va_list args;
    va_start(args, format);
    // XXX: there might be a beter way to think about this
    message_ = pool_.vsprintf(64, format, args);
    va_end(args);
}

CYPoolError::CYPoolError(const char *format, va_list args) {
    // XXX: there might be a beter way to think about this
    message_ = pool_.vsprintf(64, format, args);
}

_visible void CYThrow(const char *format, ...) {
    va_list args;
    va_start(args, format);
    throw CYPoolError(format, args);
    // XXX: does this matter? :(
    va_end(args);
}
