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

#ifndef CYCRIPT_POOLING_HPP
#define CYCRIPT_POOLING_HPP

#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include <algorithm>

#ifdef _MSC_VER
#include <malloc.h>
#endif
#include <stdint.h>

#include "Exception.hpp"
#include "Local.hpp"
#include "Standard.hpp"

// XXX: std::aligned_storage and alignof
static const size_t CYAlignment(sizeof(void *));

template <typename Type_>
static void CYAlign(Type_ &data, size_t size) {
    data = (Type_)((((uintptr_t)data) + (size - 1)) & ~static_cast<uintptr_t>(size - 1));
}

class CYPool;
_finline void *operator new(size_t size, CYPool &pool);
_finline void *operator new [](size_t size, CYPool &pool);

class CYPool {
  private:
    uint8_t *data_;
    size_t size_;
    size_t next_;

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

    template <typename Type_>
    static void delete_(void *data) {
        reinterpret_cast<Type_ *>(data)->~Type_();
    }

    CYPool(const CYPool &);

  public:
    CYPool(size_t next = 64) :
        data_(NULL),
        size_(0),
        next_(next),
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
    Type_ *malloc(size_t size, size_t alignment = CYAlignment) {
        uint8_t *end(data_);
        CYAlign(end, alignment);
        end += size;

        if (size_t(end - data_) > size_) {
            size_t need(sizeof(Cleaner));
            CYAlign(need, alignment);
            need += size;
            size_ = std::max<size_t>(next_, need);
            next_ *= 2;
            data_ = reinterpret_cast<uint8_t *>(::malloc(size_));
            atexit(free, data_);
            _assert(size <= size_);
        }

        uint8_t *data(data_);
        CYAlign(data, alignment);
        end = data + size;
        size_ -= end - data_;
        data_ = end;
        return reinterpret_cast<Type_ *>(data);
    }

    template <typename Type_>
    Type_ *calloc(size_t count, size_t size, size_t alignment = CYAlignment) {
        Type_ *data(malloc<Type_>(count * size, alignment));
        memset(data, 0, count * size);
        return data;
    }

    char *strdup(const char *data) {
        if (data == NULL)
            return NULL;
        return memdup(data, strlen(data) + 1, 1);
    }

    template <typename Type_>
    Type_ *memdup(const Type_ *data, size_t size, size_t alignment = CYAlignment) {
        Type_ *copy(malloc<Type_>(size, alignment));
        memcpy(copy, data, size);
        return copy;
    }

    char *strndup(const char *data, size_t size) {
        return strmemdup(data, strnlen(data, size));
    }

    char *strmemdup(const char *data, size_t size) {
        char *copy(malloc<char>(size + 1, 1));
        memcpy(copy, data, size);
        copy[size] = '\0';
        return copy;
    }

    // XXX: this could be made much more efficient
    _sentinel
    char *strcat(const char *data, ...) {
        size_t size(strlen(data)); {
            va_list args;
            va_start(args, data);

            while (const char *arg = va_arg(args, const char *))
                size += strlen(arg);

            va_end(args);
        }

        char *copy(malloc<char>(size + 1, 1)); {
            va_list args;
            va_start(args, data);

            size_t offset(strlen(data));
            memcpy(copy, data, offset);

            while (const char *arg = va_arg(args, const char *)) {
                size_t size(strlen(arg));
                memcpy(copy + offset, arg, size);
                offset += size;
            }

            va_end(args);
        }

        copy[size] = '\0';
        return copy;
    }

    // XXX: most people using this might should use sprintf
    char *itoa(long value) {
        return sprintf(16, "%ld", value);
    }

#ifndef _MSC_VER
    __attribute__((__format__(__printf__, 3, 4)))
#endif
    char *sprintf(size_t size, const char *format, ...) {
        va_list args;
        va_start(args, format);
        char *copy(vsprintf(size, format, args));
        va_end(args);
        return copy;
    }

    char *vsprintf(size_t size, const char *format, va_list args) {
        va_list copy;
        va_copy(copy, args);
        char *buffer = static_cast<char*>(alloca(size));
        int writ(vsnprintf(buffer, size, format, copy));
        va_end(copy);
        _assert(writ >= 0);

        if (size_t(writ) >= size)
            return vsprintf(writ + 1, format, args);
        return strmemdup(buffer, writ);
    }

    void atexit(void (*code)(void *), void *data = NULL);

    template <typename Type_>
    Type_ &object() {
        Type_ *value(new(*this) Type_());
        atexit(&delete_<Type_>, value);
        return *value;
    }
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

struct CYData {
    CYPool *pool_;
    unsigned count_;

    CYData() :
        count_(1)
    {
        _assert(pool_ != NULL);
    }

    CYData(CYPool &pool) :
        pool_(&pool),
        count_(_not(unsigned))
    {
    }

    virtual ~CYData() {
    }

    static void *operator new(size_t size, CYPool &pool) {
        void *data(pool.malloc<void>(size));
        reinterpret_cast<CYData *>(data)->pool_ = &pool;
        return data;
    }

    static void *operator new(size_t size) {
        return operator new(size, *new CYPool());
    }

    static void operator delete(void *data) {
        delete reinterpret_cast<CYData *>(data)->pool_;
    }
};

template <typename Type_>
struct CYPoolAllocator {
    CYPool *pool_;

    typedef Type_ value_type;
    typedef value_type *pointer;
    typedef const value_type *const_pointer;
    typedef value_type &reference;
    typedef const value_type &const_reference;
    typedef std::size_t size_type;
    typedef std::ptrdiff_t difference_type;

    CYPoolAllocator() :
        pool_(NULL)
    {
    }

    template <typename Right_>
    CYPoolAllocator(const CYPoolAllocator<Right_> &rhs) :
        pool_(rhs.pool_)
    {
    }

    pointer allocate(size_type size, const void *hint = 0) {
        return pool_->malloc<value_type>(size);
    }

    void deallocate(pointer data, size_type size) {
    }

    void construct(pointer address, const Type_ &rhs) {
        new(address) Type_(rhs);
    }

    void destroy(pointer address) {
        address->~Type_();
    }

    template <typename Right_>
    inline bool operator==(const CYPoolAllocator<Right_> &rhs) {
        return pool_ == rhs.pool_;
    }

    template <typename Right_>
    inline bool operator!=(const CYPoolAllocator<Right_> &rhs) {
        return !operator==(rhs);
    }

    template <typename Right_>
    struct rebind {
        typedef CYPoolAllocator<Right_> other;
    };
};

class CYLocalPool :
    public CYPool
{
  private:
    CYLocal<CYPool> local_;

  public:
    CYLocalPool() :
        CYPool(),
        local_(this)
    {
    }
};

#define $pool \
    (*CYLocal<CYPool>::Get())

#endif/*CYCRIPT_POOLING_HPP*/
