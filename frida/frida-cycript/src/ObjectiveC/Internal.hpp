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

#ifndef CYCRIPT_OBJECTIVEC_INTERNAL_HPP
#define CYCRIPT_OBJECTIVEC_INTERNAL_HPP

#include <objc/objc.h>

#include "../Internal.hpp"

struct Selector_privateData :
    CYRoot
{
    SEL value_;

    _finline Selector_privateData(SEL value) :
        value_(value)
    {
    }
};

struct Instance :
    CYRoot
{
    typedef unsigned Flags;
    static const Flags None = 0;
    static const Flags Permanent = 1 << 0;
    static const Flags Uninitialized = 1 << 1;

    id value_;
    Flags flags_;

    Instance(id value, Flags flags);
    virtual ~Instance();

    JSValueRef GetPrototype(JSContextRef context) const;

    static JSClassRef GetClass(id value, Flags flags);

    _finline bool IsPermanent() const {
        return (flags_ & Permanent) != 0;
    }

    _finline bool IsUninitialized() const {
        return (flags_ & Uninitialized) != 0;
    }
};

struct Block :
    Instance
{
    using Instance::Instance;
};

struct Constructor :
    Instance
{
    using Instance::Instance;
};

namespace cy {
struct Super :
    CYRoot
{
    id value_;
    Class class_;

    _finline Super(id value, Class _class) :
        value_(value),
        class_(_class)
    {
    }
}; }

struct Prototype :
    CYRoot
{
};

struct Messages :
    CYRoot
{
    static constexpr const char *const Cache_ = "p";

    Class value_;

    _finline Messages(Class value) :
        value_(value)
    {
    }

    JSValueRef GetPrototype(JSContextRef context) const;
};

struct Interior :
    CYRoot
{
    id value_;
    CYProtect owner_;

    _finline Interior(id value, JSContextRef context, JSObjectRef owner) :
        value_(value),
        owner_(context, owner)
    {
    }
};

#endif/*CYCRIPT_OBJECTIVEC_INTERNAL_HPP*/
