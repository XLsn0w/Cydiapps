/* Cydia - iPhone UIKit Front-End for Debian APT
 * Copyright (C) 2008-2013  Jay Freeman (saurik)
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

#ifndef Substrate_HPP
#define Substrate_HPP

#include <objc/runtime.h>

template <typename Type_>
static inline Type_ &MSHookIvar(id self, const char *name) {
    Ivar ivar(class_getInstanceVariable(object_getClass(self), name));
    void *pointer(ivar == NULL ? NULL : reinterpret_cast<char *>(self) + ivar_getOffset(ivar));
    return *reinterpret_cast<Type_ *>(pointer);
}

#define MSClassHook(name) \
    @class name; \
    static Class $ ## name = objc_getClass(#name);

#define MSHook(type, name, args...) \
    static type (*_ ## name)(args); \
    static type $ ## name(args)

#define CYHook(Type, Code, Name) \
static struct Type ## $ ## Code { Type ## $ ## Code() { \
    Method Type ## $ ## Code(class_getInstanceMethod($ ## Type, @selector(Name))); \
    if (Type ## $ ## Code != NULL) { \
        _ ## Type ## $ ## Code = reinterpret_cast<decltype(_ ## Type ## $ ## Code)>(method_getImplementation(Type ## $ ## Code)); \
        method_setImplementation(Type ## $ ## Code, reinterpret_cast<IMP>(&$ ## Type ## $ ## Code)); \
    } \
} } Type ## $ ## Code;

#endif//Substrate_HPP
