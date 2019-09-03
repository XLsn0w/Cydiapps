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

#ifndef CYCRIPT_LIST_HPP
#define CYCRIPT_LIST_HPP

#include "Exception.hpp"

template <typename Type_>
struct CYNext {
    Type_ *next_;

    CYNext() :
        next_(NULL)
    {
    }

    CYNext(Type_ *next) :
        next_(next)
    {
    }

    void SetNext(Type_ *next) {
        next_ = next;
    }
};

template <typename Type_>
Type_ *&CYSetLast(Type_ *&list) {
    if (list == NULL)
        return list;

    Type_ *next(list);
    while (next->next_ != NULL)
        next = next->next_;
    return next->next_;
}

template <typename Type_>
Type_ *&CYGetLast(Type_ *&list) {
    if (list == NULL)
        return list;

    Type_ **next(&list);
    while ((*next)->next_ != NULL)
        next = &(*next)->next_;
    return *next;
}

template <typename Type_>
struct CYList {
    Type_ *first_;
    Type_ *last_;

    CYList() :
        first_(NULL),
        last_(NULL)
    {
    }

    CYList(Type_ *first) :
        first_(first),
        last_(CYGetLast(first))
    {
    }

    CYList(Type_ *first, Type_ *last) :
        first_(first),
        last_(last)
    {
    }

    operator Type_ *() const {
        return first_;
    }

    Type_ *operator ->() const {
        return first_;
    }

    CYList &operator ->*(Type_ *next) {
        if (next != NULL) {
            if (first_ == NULL) {
                first_ = next;
                last_ = next;
            } else {
                _assert(last_->next_ == NULL);
                last_->next_ = next;
                last_ = next;
            }
        }
        return *this;
    }

    CYList &operator ->*(CYList &next) {
        if (*this == NULL)
            *this = next;
        else if (next != NULL) {
            last_->next_ = next.first_;
            last_ = next.last_;
        }
        return *this;
    }
};

#define CYForEach(value, list) \
    for (auto value(list); value != NULL; value = value->next_)

#endif/*CYCRIPT_LIST_HPP*/
