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

#ifndef CODE_HPP
#define CODE_HPP

#include <iostream>

#include "String.hpp"

class CYStream :
    public std::streambuf
{
  public:
    CYStream(const char *start, const char *end) {
        setg(const_cast<char *>(start), const_cast<char *>(start), const_cast<char *>(end));
    }
};

CYUTF8String CYPoolCode(CYPool &pool, std::streambuf &stream);
CYUTF8String CYPoolCode(CYPool &pool, CYUTF8String code);

#endif//CODE_HPP
