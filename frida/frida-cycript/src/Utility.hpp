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

#ifndef CYCRIPT_UTILITY_HPP
#define CYCRIPT_UTILITY_HPP

// XXX: this is required because Apple is bad at developer tools (I hate them so much)

namespace cy {

template <class T> struct is_lvalue_reference      { static const bool value = false; };
template <class T> struct is_lvalue_reference<T &> { static const bool value = true; };

template <class T> struct remove_reference       { typedef T type; };
template <class T> struct remove_reference<T &>  { typedef T type; };
template <class T> struct remove_reference<T &&> { typedef T type; };

template <class T>
inline T &&Forward(typename cy::remove_reference<T>::type &t) noexcept {
    return static_cast<T &&>(t);
}

template <class T>
inline T &&Forward(typename cy::remove_reference<T>::type &&t) noexcept {
    static_assert(!cy::is_lvalue_reference<T>::value, "Can not forward an rvalue as an lvalue.");
    return static_cast<T &&>(t);
}

template<class T>
inline typename cy::remove_reference<T>::type &&Move(T &&t) {
    return static_cast<typename cy::remove_reference<T>::type &&>(t);
}

template<bool B, typename T = void> struct EnableIf {};
template<typename T>                struct EnableIf<true, T> { typedef T type; };

}

#endif/*CYCRIPT_UTILITY_HPP*/
