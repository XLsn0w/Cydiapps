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

#ifndef CYCRIPT_LOCATION_HPP
#define CYCRIPT_LOCATION_HPP

#include <iostream>

class CYPosition {
  public:
    std::string *filename;
    unsigned int line;
    unsigned int column;

    CYPosition() :
        filename(NULL),
        line(1),
        column(0)
    {
    }

    void Lines(unsigned count = 1) {
        column = 0;
        line += count;
    }

    void Columns(unsigned count = 1) {
        column += count;
    }
};

inline std::ostream &operator <<(std::ostream &out, const CYPosition &position) {
    if (position.filename != NULL)
        out << *position.filename << ":";
    out << position.line << "." << position.column;
    return out;
}

class CYLocation {
  public:
    CYPosition begin;
    CYPosition end;

    void step() {
        begin = end;
    }
};

inline std::ostream &operator <<(std::ostream &out, const CYLocation &location) {
    const CYPosition &begin(location.begin);
    const CYPosition &end(location.end);

    out << begin;
    if (end.filename != NULL && (begin.filename == NULL || *begin.filename != *end.filename))
        out << '-' << *end.filename << ':' << end.line << '.' << end.column;
    else if (begin.line != end.line)
        out << '-' << end.line << '.' << end.column;
    else if (begin.column != end.column)
        out << '-' << end.column;
    return out;
}

#endif/*CYCRIPT_LOCATION_HPP*/
