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

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include "Pooling.hpp"
#include "sig/parse.hpp"

namespace sig {

void Copy(CYPool &pool, Element &lhs, const Element &rhs) {
    lhs.name = pool.strdup(rhs.name);
    _assert(rhs.type != NULL);
    lhs.type = rhs.type->Copy(pool);
    lhs.offset = rhs.offset;
}

void Copy(CYPool &pool, Signature &lhs, const Signature &rhs) {
    size_t count(rhs.count);
    lhs.count = count;
    if (count == _not(size_t))
        lhs.elements = NULL;
    else {
        lhs.elements = new(pool) Element[count];
        for (size_t index(0); index != count; ++index)
            Copy(pool, lhs.elements[index], rhs.elements[index]);
    }
}

Void *Void::Copy(CYPool &pool, const char *rename) const {
    return Flag(new(pool) Void());
}

Unknown *Unknown::Copy(CYPool &pool, const char *rename) const {
    return Flag(new(pool) Unknown());
}

String *String::Copy(CYPool &pool, const char *rename) const {
    return Flag(new(pool) String());
}

#if CY_OBJECTIVEC
Meta *Meta::Copy(CYPool &pool, const char *rename) const {
    return Flag(new(pool) Meta());
}

Selector *Selector::Copy(CYPool &pool, const char *rename) const {
    return Flag(new(pool) Selector());
}
#endif

Bits *Bits::Copy(CYPool &pool, const char *rename) const {
    return Flag(new(pool) Bits(size));
}

Pointer *Pointer::Copy(CYPool &pool, const char *rename) const {
    return Flag(new(pool) Pointer(*type.Copy(pool)));
}

Array *Array::Copy(CYPool &pool, const char *rename) const {
    return Flag(new(pool) Array(*type.Copy(pool), size));
}

#if CY_OBJECTIVEC
Object *Object::Copy(CYPool &pool, const char *rename) const {
    return Flag(new(pool) Object(pool.strdup(name)));
}
#endif

Enum *Enum::Copy(CYPool &pool, const char *rename) const {
    if (rename == NULL)
        rename = pool.strdup(name);
    else if (rename[0] == '\0')
        rename = NULL;
    Enum *copy(new(pool) Enum(*type.Copy(pool), count, rename));
    copy->constants = new(pool) Constant[count];
    for (size_t i(0); i != count; ++i) {
        copy->constants[i].name = pool.strdup(constants[i].name);
        copy->constants[i].value = constants[i].value;
    }
    return Flag(copy);
}

Aggregate *Aggregate::Copy(CYPool &pool, const char *rename) const {
    if (rename == NULL)
        rename = pool.strdup(name);
    else if (rename[0] == '\0')
        rename = NULL;
    Aggregate *copy(new(pool) Aggregate(overlap, rename));
    sig::Copy(pool, copy->signature, signature);
    return Flag(copy);
}

Function *Function::Copy(CYPool &pool, const char *rename) const {
    Function *copy(new(pool) Function(variadic));
    sig::Copy(pool, copy->signature, signature);
    return Flag(copy);
}

#if CY_OBJECTIVEC
Block *Block::Copy(CYPool &pool, const char *rename) const {
    Block *copy(new(pool) Block());
    sig::Copy(pool, copy->signature, signature);
    return Flag(copy);
}
#endif

const char *Type::GetName() const {
    return NULL;
}

const char *Enum::GetName() const {
    return name;
}

const char *Aggregate::GetName() const {
    return name;
}

}
