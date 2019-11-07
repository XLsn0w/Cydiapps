/* Minimal - the simplest thing that could possibly work
 * Copyright (C) 2007  Jay Freeman (saurik)
*/

/*
 *        Redistribution and use in source and binary
 * forms, with or without modification, are permitted
 * provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the
 *    above copyright notice, this list of conditions
 *    and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the
 *    above copyright notice, this list of conditions
 *    and the following disclaimer in the documentation
 *    and/or other materials provided with the
 *    distribution.
 * 3. The name of the author may not be used to endorse
 *    or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
 * BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef MINIMAL_SQLITE3_H
#define MINIMAL_SQLITE3_H

#include <sqlite3.h>
#include <string.h>

#define _sqlcall(expr) ({ \
    __typeof__(expr) _value = (expr); \
    if (_value != 0 && (_value < 100 || _value >= 200)) \
        _assert(false, "_sqlcall(%u:%s): %s\n", _value, #expr, sqlite3_errmsg(database_)); \
    _value; \
})

int sqlite3_bind_string(sqlite3_stmt *stmt, int n, const char *value) {
    if (value == NULL)
        return sqlite3_bind_null(stmt, n);
    else
        return sqlite3_bind_text(stmt, n, strdup(value), -1, &free);
}

int sqlite3_bind_boolean(sqlite3_stmt *stmt, int n, bool value) {
    return sqlite3_bind_int(stmt, n, value ? 1 : 0);
}

char *sqlite3_column_string(sqlite3_stmt *stmt, int n) {
    const unsigned char *value = sqlite3_column_text(stmt, n);
    return value == NULL ? NULL : strdup((const char *) value);
}

bool sqlite3_column_boolean(sqlite3_stmt *stmt, int n) {
    return sqlite3_column_int(stmt, n) != 0;
}

#endif/*MINIMAL_SQLITE3_H*/
