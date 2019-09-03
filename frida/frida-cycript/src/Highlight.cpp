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

#include "Code.hpp"
#include "Driver.hpp"
#include "Highlight.hpp"

bool CYLexerHighlight(hi::Value &highlight, CYLocation &location, void *scanner);

static void Skip(const char *data, size_t size, std::ostream &output, size_t &offset, CYPosition &current, CYPosition target) {
    while (current.line != target.line || current.column != target.column) {
        _assert(offset != size);
        char next(data[offset++]);

        output.put(next);

        _assert(current.line < target.line || current.line == target.line && current.column < target.column);
        if (next == '\n')
            current.Lines();
        else
            current.Columns();
    }
}

struct CYColor {
    bool bold_;
    unsigned code_;

    CYColor() {
    }

    CYColor(bool bold, unsigned code) :
        bold_(bold),
        code_(code)
    {
    }
};

_visible void CYLexerHighlight(const char *data, size_t size, std::ostream &output, bool ignore) {
    CYLocalPool pool;

    CYStream stream(data, data + size);
    CYDriver driver(pool, stream);
    driver.highlight_ = true;

    size_t offset(0);
    CYPosition current;

    hi::Value highlight;
    CYLocation location;

    while (CYLexerHighlight(highlight, location, driver.scanner_)) {
        CYColor color;

        switch (highlight) {
            case hi::Comment: color = CYColor(true, 30); break;
            case hi::Constant: color = CYColor(false, 31); break;
            case hi::Control: color = CYColor(false, 33); break;
            case hi::Error: color = CYColor(true, 31); break;
            case hi::Identifier: color = CYColor(false, 0); break;
            case hi::Meta: color = CYColor(false, 32); break;
            case hi::Nothing: color = CYColor(false, 0); break;
            case hi::Operator: color = CYColor(false, 36); break;
            case hi::Special: color = CYColor(false, 35); break;
            case hi::Structure: color = CYColor(true, 34); break;
            case hi::Type: color = CYColor(true, 34); break;

            // XXX: maybe I should use nodefault here?
            default: color = CYColor(true, 0); break;
        }

        Skip(data, size, output, offset, current, location.begin);

        if (color.code_ != 0) {
            if (ignore)
                output << CYIgnoreStart;
            output << "\033[" << (color.bold_ ? '1' : '0') << ";" << color.code_ << "m";
            if (ignore)
                output << CYIgnoreEnd;
        }

        Skip(data, size, output, offset, current, location.end);

        if (color.code_ != 0) {
            if (ignore)
                output << CYIgnoreStart;
            output << "\033[0m";
            if (ignore)
                output << CYIgnoreEnd;
        }
    }

    output.write(data + offset, size - offset);
}
