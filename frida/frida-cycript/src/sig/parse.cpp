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

#include "sig/parse.hpp"
#include "Error.hpp"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <sstream>

namespace sig {

void Parse_(CYPool &pool, struct Signature *signature, const char **name, char eos, Callback callback);
struct Type *Parse_(CYPool &pool, const char **name, char eos, bool named, Callback callback);


/* XXX: I really screwed up this time */
void *prealloc_(CYPool &pool, void *odata, size_t osize, size_t nsize) {
    void *ndata(pool.malloc<void>(nsize));
    memcpy(ndata, odata, osize);
    return ndata;
}

void Parse_(CYPool &pool, struct Signature *signature, const char **name, char eos, Callback callback) {
    _assert(*name != NULL);

    // XXX: this is just a stupid check :(
    bool named(**name == '"');

    signature->elements = NULL;
    signature->count = 0;

    for (;;) {
        if (**name == eos) {
            ++*name;
            return;
        }

        signature->elements = (struct Element *) prealloc_(pool, signature->elements, signature->count * sizeof(struct Element), (signature->count + 1) * sizeof(struct Element));
        _assert(signature->elements != NULL);

        struct Element *element = &signature->elements[signature->count++];

        if (**name != '"')
            element->name = NULL;
        else {
            const char *quote = strchr(++*name, '"');
            element->name = pool.strmemdup(*name, quote - *name);
            *name = quote + 1;
        }

        element->type = Parse_(pool, name, eos, named, callback);

        if (**name < '0' || **name > '9')
            element->offset = _not(size_t);
        else {
            element->offset = 0;

            do
                element->offset = element->offset * 10 + (*(*name)++ - '0');
            while (**name >= '0' && **name <= '9');
        }
    }
}

Type *Parse_(CYPool &pool, const char **encoding, char eos, bool named, Callback callback) {
    char next = *(*encoding)++;

    Type *type;
    uint8_t flags(0);

  parse:
    switch (next) {
        case '?': type = new(pool) Unknown(); break;

#if CY_OBJECTIVEC
        case '#': type = new(pool) Meta(); break;
#endif

        case '(':
            type = new(pool) Aggregate(true);
            next = ')';
        goto aggregate;

        case '*': type = new(pool) String(); break;

#if CY_OBJECTIVEC
        case ':': type = new(pool) Selector(); break;

        case '@': {
            char next(**encoding);

            if (next == '?') {
                type = new(pool) Block();
                ++*encoding;
            } else {
                const char *name;
                if (next != '"')
                    name = NULL;
                else {
                    const char *quote = strchr(*encoding + 1, '"');
                    if (quote == NULL)
                        CYThrow("unterminated specific id type {%s}", *encoding - 10);
                    else if (!named || quote[1] == eos || quote[1] == '"') {
                        name = pool.strmemdup(*encoding + 1, quote - *encoding - 1);
                        *encoding = quote + 1;
                    } else {
                        name = NULL;
                    }
                }

                type = new(pool) Object(name);
            }

        } break;
#endif

        case 'B': type = new(pool) Primitive<bool>(); break;
        case 'C': type = new(pool) Primitive<unsigned char>(); break;
        case 'I': type = new(pool) Primitive<unsigned int>(); break;
        case 'L': type = new(pool) Primitive<unsigned long>(); break;
        case 'Q': type = new(pool) Primitive<unsigned long long>(); break;
        case 'S': type = new(pool) Primitive<unsigned short>(); break;

        case '[': {
            size_t size(strtoul(*encoding, (char **) encoding, 10));
            type = new(pool) Array(*Parse_(pool, encoding, eos, false, callback), size);
            if (**encoding != ']')
                CYThrow("']' != \"%s\"", *encoding);
            ++*encoding;
        } break;

        case '^':
            if (**encoding == '"')
                _assert(false); // XXX: why is this here?!?
            else {
                type = Parse_(pool, encoding, eos, named, callback);
#if CY_OBJECTIVEC
                Aggregate *aggregate(dynamic_cast<Aggregate *>(type));
                if (aggregate != NULL && strcmp(aggregate->name, "_objc_class") == 0)
                    type = new(pool) Meta();
                else
#endif
                    type = new(pool) Pointer(*type);
            }
        break;

        case 'b':
            type = new(pool) Bits(strtoul(*encoding, (char **) encoding, 10));
        break;

        case 'c': type = new(pool) Primitive<signed char>(); break;
        case 'D': type = new(pool) Primitive<long double>(); break;
        case 'd': type = new(pool) Primitive<double>(); break;
        case 'f': type = new(pool) Primitive<float>(); break;
        case 'i': type = new(pool) Primitive<signed int>(); break;
        case 'l': type = new(pool) Primitive<signed long>(); break;
        case 'q': type = new(pool) Primitive<signed long long>(); break;
        case 's': type = new(pool) Primitive<short>(); break;
        case 'v': type = new(pool) Void(); break;

#ifdef __SIZEOF_INT128__
        case 't': type = new(pool) Primitive<signed __int128>(); break;
        case 'T': type = new(pool) Primitive<unsigned __int128>(); break;
#endif

        case '{':
            type = new(pool) Aggregate(false);
            next = '}';
        goto aggregate;

        aggregate: {
            Aggregate *aggregate(static_cast<Aggregate *>(type));

            char end = next;
            const char *begin = *encoding;
            do switch (next = *(*encoding)++) {
                case '\0':
                    _assert(false);
                case '}':
                    // XXX: this is actually a type reference
                    aggregate->signature.count = _not(size_t);
                    next = '='; // this is a "break". I'm sorry
            } while (next != '=');

            size_t length = *encoding - begin - 1;
            if (strncmp(begin, "?", length) != 0)
                aggregate->name = (char *) pool.strmemdup(begin, length);

            if (aggregate->signature.count == _not(size_t))
                aggregate->signature.elements = NULL;
            else
                Parse_(pool, &aggregate->signature, encoding, end, callback);

            // XXX: this is a hack to support trivial unions
            if (aggregate->signature.count <= 1)
                aggregate->overlap = false;

            if (callback != NULL)
                type = (*callback)(pool, aggregate);
        } break;

        case 'r': flags |= JOC_TYPE_CONST; goto next;

        case 'n': flags |= JOC_TYPE_IN; goto next;
        case 'N': flags |= JOC_TYPE_INOUT; goto next;
        case 'o': flags |= JOC_TYPE_OUT; goto next;
        case 'O': flags |= JOC_TYPE_BYCOPY; goto next;
        case 'R': flags |= JOC_TYPE_BYREF; goto next;
        case 'V': flags |= JOC_TYPE_ONEWAY; goto next;

        next:
            next = *(*encoding)++;
            goto parse;
        break;

        default:
            CYThrow("invalid type character: '%c' {%s}", next, *encoding - 10);
    }

    type->flags = flags;

    return type;
}

void Parse(CYPool &pool, struct Signature *signature, const char *name, Callback callback) {
    const char *temp = name;
    Parse_(pool, signature, &temp, '\0', callback);
    _assert(temp[-1] == '\0');
}

const char *Unparse(CYPool &pool, const struct Signature *signature) {
    const char *value = "";
    size_t offset;

    for (offset = 0; offset != signature->count; ++offset) {
        const char *type = Unparse(pool, signature->elements[offset].type);
        value = pool.strcat(value, type, NULL);
    }

    return value;
}

template <>
const char *Primitive<bool>::Encode(CYPool &pool) const {
    return "B";
}

template <>
const char *Primitive<char>::Encode(CYPool &pool) const {
    return "c";
}

template <>
const char *Primitive<double>::Encode(CYPool &pool) const {
    return "d";
}

template <>
const char *Primitive<float>::Encode(CYPool &pool) const {
    return "f";
}

template <>
const char *Primitive<long double>::Encode(CYPool &pool) const {
    return "D";
}

template <>
const char *Primitive<signed char>::Encode(CYPool &pool) const {
    return "c";
}

template <>
const char *Primitive<signed int>::Encode(CYPool &pool) const {
    return "i";
}

#ifdef __SIZEOF_INT128__
template <>
const char *Primitive<signed __int128>::Encode(CYPool &pool) const {
    return "t";
}
#endif

template <>
const char *Primitive<signed long int>::Encode(CYPool &pool) const {
    return "l";
}

template <>
const char *Primitive<signed long long int>::Encode(CYPool &pool) const {
    return "q";
}

template <>
const char *Primitive<signed short int>::Encode(CYPool &pool) const {
    return "s";
}

template <>
const char *Primitive<unsigned char>::Encode(CYPool &pool) const {
    return "C";
}

template <>
const char *Primitive<unsigned int>::Encode(CYPool &pool) const {
    return "I";
}

#ifdef __SIZEOF_INT128__
template <>
const char *Primitive<unsigned __int128>::Encode(CYPool &pool) const {
    return "T";
}
#endif

template <>
const char *Primitive<unsigned long int>::Encode(CYPool &pool) const {
    return "L";
}

template <>
const char *Primitive<unsigned long long int>::Encode(CYPool &pool) const {
    return "Q";
}

template <>
const char *Primitive<unsigned short int>::Encode(CYPool &pool) const {
    return "S";
}

const char *Void::Encode(CYPool &pool) const {
    return "v";
}

const char *Unknown::Encode(CYPool &pool) const {
    return "?";
}

const char *String::Encode(CYPool &pool) const {
    return "*";
}

#if CY_OBJECTIVEC
const char *Meta::Encode(CYPool &pool) const {
    return "#";
}

const char *Selector::Encode(CYPool &pool) const {
    return ":";
}
#endif

const char *Bits::Encode(CYPool &pool) const {
    return pool.strcat("b", pool.itoa(size), NULL);
}

const char *Pointer::Encode(CYPool &pool) const {
    return pool.strcat("^", type.Encode(pool), NULL);
}

const char *Array::Encode(CYPool &pool) const {
    return pool.strcat("[", pool.itoa(size), type.Encode(pool), "]", NULL);
}

#if CY_OBJECTIVEC
const char *Object::Encode(CYPool &pool) const {
    return name == NULL ? "@" : pool.strcat("@\"", name, "\"", NULL);
}
#endif

const char *Enum::Encode(CYPool &pool) const {
    return type.Encode(pool);
}

const char *Aggregate::Encode(CYPool &pool) const {
    bool reference(signature.count == _not(size_t));
    return pool.strcat(overlap ? "(" : "{",
        name == NULL ? "?" : name,
        reference ? "" : "=",
        reference ? "" : Unparse(pool, &signature),
    overlap ? ")" : "}", NULL);
}

const char *Function::Encode(CYPool &pool) const {
    return "?";
}

#if CY_OBJECTIVEC
const char *Block::Encode(CYPool &pool) const {
    return "@?";
}
#endif

const char *Unparse(CYPool &pool, const struct Type *type) {
    const char *base(type->Encode(pool));
    if (type->flags == 0)
        return base;

    #define iovec_(base, size) \
        (struct iovec) {const_cast<char *>(base), size}

    size_t size(strlen(base));
    char *buffer = static_cast<char*>(alloca(7 + size));
    size_t offset(0);

    if ((type->flags & JOC_TYPE_INOUT) != 0)
        buffer[offset++] = 'N';
    if ((type->flags & JOC_TYPE_IN) != 0)
        buffer[offset++] = 'n';
    if ((type->flags & JOC_TYPE_BYCOPY) != 0)
        buffer[offset++] = 'O';
    if ((type->flags & JOC_TYPE_OUT) != 0)
        buffer[offset++] = 'o';
    if ((type->flags & JOC_TYPE_BYREF) != 0)
        buffer[offset++] = 'R';
    if ((type->flags & JOC_TYPE_CONST) != 0)
        buffer[offset++] = 'r';
    if ((type->flags & JOC_TYPE_ONEWAY) != 0)
        buffer[offset++] = 'V';

    memcpy(buffer + offset, base, size);
    return pool.strmemdup(buffer, offset + size);
}

}
