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

#ifndef Cydia_RegEx_HPP
#define Cydia_RegEx_HPP

#include <unicode/uregex.h>

#include "CyteKit/UCPlatform.h"
#include "CyteKit/stringWithUTF8Bytes.h"

#define _rgxcall(code, args...) ({ \
    UErrorCode status(U_ZERO_ERROR); \
    auto _value(code(args, &status)); \
    if (U_FAILURE(status)) { \
        fprintf(stderr, "%d:%s\n", error.offset, u_errorName(status)); \
        _assert(false); \
    } \
_value; })

#define _rgxcallv(code, args...) ({ \
    UErrorCode status(U_ZERO_ERROR); \
    code(args, &status); \
    if (U_FAILURE(status)) { \
        fprintf(stderr, "%d:%s\n", error.offset, u_errorName(status)); \
        _assert(false); \
    } \
})

class RegEx {
  private:
    URegularExpression *regex_;
    int capture_;
    size_t size_;

  public:
    RegEx() :
        regex_(NULL),
        size_(_not(size_t))
    {
    }

    RegEx(const char *regex) :
        regex_(NULL),
        size_(_not(size_t))
    {
        this->operator =(regex);
    }

    template <typename Type_>
    RegEx(const char *regex, const Type_ &data) :
        RegEx(regex)
    {
        this->operator ()(data);
    }

    void operator =(const char *regex) {
        _assert(regex_ == NULL);
        UParseError error;
        regex_ = _rgxcall(uregex_openC, regex, 0, &error);
        capture_ = _rgxcall(uregex_groupCount, regex_);
    }

    ~RegEx() {
        uregex_close(regex_);
    }

    NSString *operator [](size_t match) const {
        UParseError error;
        size_t size(size_);
        UChar data[size];
        size = _rgxcall(uregex_group, regex_, match, data, size);
        return [[[NSString alloc] initWithBytes:data length:(size * sizeof(UChar)) encoding:NSUTF16LittleEndianStringEncoding] autorelease];
    }

    _finline bool operator ()(NSString *string) {
        return operator ()(reinterpret_cast<const uint16_t *>([string cStringUsingEncoding:NSUTF16LittleEndianStringEncoding]), [string length]);
    }

    _finline bool operator ()(const char *data) {
        return operator ()([NSString stringWithUTF8String:data]);
    }

    bool operator ()(const UChar *data, size_t size) {
        UParseError error;
        _rgxcallv(uregex_setText, regex_, data, size);

        if (_rgxcall(uregex_matches, regex_, -1)) {
            size_ = size;
            return true;
        } else {
            size_ = _not(size_t);
            return false;
        }
    }

    bool operator ()(const char *data, size_t size) {
        return operator ()([[[NSString alloc] initWithBytes:data length:size encoding:NSUTF8StringEncoding] autorelease]);
    }

    operator bool() const {
        return size_ != _not(size_t);
    }

    NSString *operator ->*(NSString *format) const {
        id values[capture_];
        for (int i(0); i != capture_; ++i)
            values[i] = this->operator [](i + 1);
        return [[[NSString alloc] initWithFormat:format arguments:reinterpret_cast<va_list>(values)] autorelease];
    }
};

#endif//Cydia_RegEx_HPP
