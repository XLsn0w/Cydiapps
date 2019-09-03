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

#ifndef CYCRIPT_INTERNAL_HPP
#define CYCRIPT_INTERNAL_HPP

#include <sig/parse.hpp>

#include "JavaScript.hpp"
#include "Pooling.hpp"
#include "Utility.hpp"

struct CYPropertyName;

sig::Type *Structor_(CYPool &pool, sig::Aggregate *aggregate);

struct CYRoot :
    CYData
{
    // XXX: without this, CYData is zero-initialized?!
    CYRoot() :
        CYData()
    {
    }
};

struct Type_privateData :
    CYRoot
{
    sig::Type *type_;

    Type_privateData(const char *type)
    {
        sig::Signature signature;
        sig::Parse(*pool_, &signature, type, &Structor_);
        type_ = signature.elements[0].type;
    }

    Type_privateData(const sig::Type &type) :
        type_(type.Copy(*pool_))
    {
    }
};

namespace cy {
struct Functor :
    CYRoot
{
  public:
    void (*value_)();
    bool variadic_;
    sig::Signature signature_;

    Functor(void (*value)(), bool variadic, const sig::Signature &signature) :
        value_(value),
        variadic_(variadic)
    {
        sig::Copy(*pool_, signature_, signature);
    }

    Functor(void (*value)(), const char *encoding) :
        value_(value),
        variadic_(false)
    {
        sig::Parse(*pool_, &signature_, encoding, &Structor_);
    }

    virtual CYPropertyName *GetName(CYPool &pool) const;
}; }

#endif/*CYCRIPT_INTERNAL_HPP*/
