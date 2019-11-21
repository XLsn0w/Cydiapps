/* Cycript - Optimizing JavaScript Compiler/Runtime
 * Copyright (C) 2009-2015  Jay Freeman (saurik)
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

#ifndef Menes_Pooling_HPP
#define Menes_Pooling_HPP

#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include <algorithm>

#include <stdint.h>

class CYPool;
_finline void *operator new(size_t size, CYPool &pool);
_finline void *operator new [](size_t size, CYPool &pool);

class CYPool {
  private:
    uint8_t *data_;
    size_t size_;

    struct Cleaner {
        Cleaner *next_;
        void (*code_)(void *);
        void *data_;

        Cleaner(Cleaner *next, void (*code)(void *), void *data) :
            next_(next),
            code_(code),
            data_(data)
        {
        }
    } *cleaner_;

    static _finline size_t align(size_t size) {
        // XXX: alignment is more complex than this
        return (size + 7) & ~0x3;
    }

    template <typename Type_>
    static void delete_(void *data) {
        reinterpret_cast<Type_ *>(data)->~Type_();
    }

    CYPool(const CYPool &);

  public:
    CYPool() :
        data_(NULL),
        size_(0),
        cleaner_(NULL)
    {
    }

    ~CYPool() {
        for (Cleaner *cleaner(cleaner_); cleaner != NULL; ) {
            Cleaner *next(cleaner->next_);
            (*cleaner->code_)(cleaner->data_);
            cleaner = next;
        }
    }

    template <typename Type_>
    Type_ *malloc(size_t size) {
        size = align(size);

        if (size > size_) {
            // XXX: is this an optimal malloc size?
            size_ = std::max<size_t>(size, size + align(sizeof(Cleaner)));
            data_ = reinterpret_cast<uint8_t *>(::malloc(size_));
            atexit(free, data_);
            _assert(size <= size_);
        }

        void *data(data_);
        data_ += size;
        size_ -= size;
        return reinterpret_cast<Type_ *>(data);
    }

    void atexit(void (*code)(void *), void *data = NULL);
};

_finline void *operator new(size_t size, CYPool &pool) {
    return pool.malloc<void>(size);
}

_finline void *operator new [](size_t size, CYPool &pool) {
    return pool.malloc<void>(size);
}

_finline void CYPool::atexit(void (*code)(void *), void *data) {
    cleaner_ = new(*this) Cleaner(cleaner_, code, data);
}

#endif/*Menes_Pooling_HPP*/
