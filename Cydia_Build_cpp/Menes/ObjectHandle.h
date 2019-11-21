/* Cydia - iPhone UIKit Front-End for Debian APT
 * Copyright (C) 2008-2015  Jay Freeman (saurik)
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

#ifndef Menes_ObjectHandle_H
#define Menes_ObjectHandle_H

#include <CoreFoundation/CoreFoundation.h>
#include <Foundation/Foundation.h>

template <typename Type_, unsigned Delegate_>
struct MenesObjectHandle_;

template <typename Type_>
struct MenesObjectHandle_<Type_, 0> {
    static _finline void Execute(Type_ *value) {
    }
};

template <typename Type_>
struct MenesObjectHandle_<Type_, 1> {
    static _finline void Execute(Type_ *value) {
        [value setDelegate:nil];
    }
};

template <typename Type_>
struct MenesObjectHandle_<Type_, 2> {
    static _finline void Execute(Type_ *value) {
        [value setDelegate:nil];
        [value setDataSource:nil];
    }
};

template <typename Type_, unsigned Delegate_ = 0>
class MenesObjectHandle {
  private:
    Type_ *value_;

    _finline void Retain_() {
        if (value_ != nil)
            CFRetain((CFTypeRef) value_);
    }

    _finline void Release_(Type_ *value) {
        if (value != nil) {
            MenesObjectHandle_<Type_, Delegate_>::Execute(value);
            CFRelease((CFTypeRef) value);
        }
    }

  public:
    _finline MenesObjectHandle(const MenesObjectHandle &rhs) :
        value_(rhs.value_ == nil ? nil : (Type_ *) CFRetain((CFTypeRef) rhs.value_))
    {
    }

    _finline MenesObjectHandle(Type_ *value = NULL, bool mended = false) :
        value_(value)
    {
        if (!mended)
            Retain_();
    }

    _finline ~MenesObjectHandle() {
        Release_(value_);
    }

    _finline operator Type_ *() const {
        return value_;
    }

    _finline Type_ *operator ->() const {
        return value_;
    }

    _finline MenesObjectHandle &operator =(Type_ *value) {
        if (value_ != value) {
            Type_ *old(value_);
            value_ = value;
            Retain_();
            Release_(old);
        } return *this;
    }

    _finline MenesObjectHandle &operator =(const MenesObjectHandle &value) {
        return this->operator =(value.operator Type_ *());
    }
};

#define _H MenesObjectHandle

#define rproperty_(Class, field) \
    - (typeof(((Class*)nil)->_##field.operator->())) field { \
        return _##field; \
    }

#define wproperty_(Class, field, Field) \
    - (void) set##Field:(typeof(((Class*)nil)->_##field.operator->()))field { \
        _##field = field; \
    }

#define roproperty(Class, field) \
@implementation Class (Menes_##field) \
rproperty_(Class, field) \
@end

#define rwproperty(Class, field, Field) \
@implementation Class (Menes_##field) \
rproperty_(Class, field) \
wproperty_(Class, field, Field) \
@end

// XXX: I hate clang. Apple: please get over your petty hatred of GPL and fix your gcc fork
#define synchronized(lock) \
    synchronized(static_cast<NSObject *>(lock))

#endif//Menes_ObjectHandle_H
