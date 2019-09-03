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

#ifndef FUNCTOR_HPP
#define FUNCTOR_HPP

template <typename Function_>
class Functor;

template <typename Type_, typename... Args_>
class Functor<Type_ (Args_...)> {
  public:
    virtual Type_ operator ()(Args_... args) const = 0;
};

template <typename Function_>
class FunctorImpl;

template <typename Value_, typename Type_, typename... Args_>
class FunctorImpl<Type_ (Value_::*)(Args_...) const> :
    public Functor<Type_ (Args_...)>
{
  private:
    const Value_ *value_;

  public:
    FunctorImpl(const Value_ &value) :
        value_(&value)
    {
    }

    virtual Type_ operator ()(Args_... args) const {
        return (*value_)(args...);
    }
};

template <typename Function_>
FunctorImpl<decltype(&Function_::operator())> fun(const Function_ &value) {
    return value;
}

#endif//FUNCTOR_HPP
