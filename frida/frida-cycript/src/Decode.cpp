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

#include <sstream>

#include "Decode.hpp"
#include "Replace.hpp"

namespace sig {

template <>
CYType *Primitive<bool>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeVariable("bool"));
}

template <>
CYType *Primitive<char>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeCharacter(CYTypeNeutral));
}

template <>
CYType *Primitive<double>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeFloating(1));
}

template <>
CYType *Primitive<float>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeFloating(0));
}

template <>
CYType *Primitive<long double>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeFloating(2));
}

template <>
CYType *Primitive<signed char>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeCharacter(CYTypeSigned));
}

template <>
CYType *Primitive<signed int>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeIntegral(CYTypeSigned, 1));
}

#ifdef __SIZEOF_INT128__
template <>
CYType *Primitive<signed __int128>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeInt128(CYTypeSigned));
}
#endif

template <>
CYType *Primitive<signed long int>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeIntegral(CYTypeSigned, 2));
}

template <>
CYType *Primitive<signed long long int>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeIntegral(CYTypeSigned, 3));
}

template <>
CYType *Primitive<signed short int>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeIntegral(CYTypeSigned, 0));
}

template <>
CYType *Primitive<unsigned char>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeCharacter(CYTypeUnsigned));
}

template <>
CYType *Primitive<unsigned int>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeIntegral(CYTypeUnsigned, 1));
}

#ifdef __SIZEOF_INT128__
template <>
CYType *Primitive<unsigned __int128>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeInt128(CYTypeUnsigned));
}
#endif

template <>
CYType *Primitive<unsigned long int>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeIntegral(CYTypeUnsigned, 2));
}

template <>
CYType *Primitive<unsigned long long int>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeIntegral(CYTypeUnsigned, 3));
}

template <>
CYType *Primitive<unsigned short int>::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeIntegral(CYTypeUnsigned, 0));
}

CYType *Void::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeVoid());
}

CYType *Unknown::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeError());
}

CYType *String::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeCharacter(CYTypeNeutral), $ CYTypePointerTo());
}

#if CY_OBJECTIVEC
CYType *Meta::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeVariable("Class"));
}

CYType *Selector::Decode(CYPool &pool) const {
    return $ CYType($ CYTypeVariable("SEL"));
}
#endif

CYType *Bits::Decode(CYPool &pool) const {
    _assert(false);
    return NULL;
}

CYType *Pointer::Decode(CYPool &pool) const {
    return CYDecodeType(pool, &type)->Modify($ CYTypePointerTo());
}

CYType *Array::Decode(CYPool &pool) const {
    return CYDecodeType(pool, &type)->Modify($ CYTypeArrayOf($D(size)));
}

#if CY_OBJECTIVEC
CYType *Object::Decode(CYPool &pool) const {
    if (name == NULL)
        return $ CYType($ CYTypeVariable("id"));
    else
        return $ CYType($ CYTypeVariable(name), $ CYTypePointerTo());
}
#endif

CYType *Enum::Decode(CYPool &pool) const {
    CYEnumConstant *values(NULL);
    for (size_t i(count); i != 0; --i)
        values = $ CYEnumConstant($I(pool.strdup(constants[i - 1].name)), $D(constants[i - 1].value), values);
    CYIdentifier *identifier(name == NULL ? NULL : $I(name));
    CYType *typed(type.Decode(pool));
    _assert(typed->modifier_ == NULL);
    return $ CYType($ CYTypeEnum(identifier, typed->specifier_, values));
}

CYType *Aggregate::Decode(CYPool &pool) const {
    _assert(!overlap);

    if (signature.count == _not(size_t)) {
        _assert(name != NULL);
        return $ CYType($ CYTypeReference(CYTypeReferenceStruct, $I($pool.strdup(name))));
    }

    CYTypeStructField *fields(NULL);
    for (size_t i(signature.count); i != 0; --i) {
        sig::Element &element(signature.elements[i - 1]);
        fields = $ CYTypeStructField(CYDecodeType(pool, element.type), element.name == NULL ? NULL : $I(element.name), fields);
    }
    CYIdentifier *identifier(name == NULL ? NULL : $I(name));
    return $ CYType($ CYTypeStruct(identifier, $ CYStructTail(fields)));
}

CYType *Callable::Decode(CYPool &pool) const {
    _assert(signature.count != 0);
    CYTypedParameter *parameters(NULL);
    for (size_t i(signature.count - 1); i != 0; --i)
        parameters = $ CYTypedParameter(CYDecodeType(pool, signature.elements[i].type), NULL, parameters);
    return Modify(pool, CYDecodeType(pool, signature.elements[0].type), parameters);
}

CYType *Function::Modify(CYPool &pool, CYType *result, CYTypedParameter *parameters) const {
    return result->Modify($ CYTypeFunctionWith(variadic, parameters));
}

#if CY_OBJECTIVEC
CYType *Block::Modify(CYPool &pool, CYType *result, CYTypedParameter *parameters) const {
    return result->Modify($ CYTypeBlockWith(parameters));
}

CYType *Block::Decode(CYPool &pool) const {
    if (signature.count == 0)
        return $ CYType($ CYTypeVariable("NSBlock"), $ CYTypePointerTo());
    return Callable::Decode(pool);
}
#endif

}

CYType *CYDecodeType(CYPool &pool, struct sig::Type *type) {
    CYType *typed(type->Decode(pool));
    if ((type->flags & JOC_TYPE_CONST) != 0) {
        if (dynamic_cast<sig::String *>(type) != NULL)
            typed->modifier_ = $ CYTypeConstant(typed->modifier_);
        else
            typed = typed->Modify($ CYTypeConstant());
    }
    return typed;
}
