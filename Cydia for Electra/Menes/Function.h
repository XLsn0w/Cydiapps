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

#ifndef Menes_Function_H
#define Menes_Function_H

template <typename Result_, typename... Args_>
class Function {
  private:
    class Abstract {
      private:
        unsigned references_;

      public:
        Abstract() :
            references_(0)
        {
        }

        Abstract(const Abstract &) = delete;
        Abstract &operator =(const Abstract &) = delete;

        virtual ~Abstract() {
        }

        void Retain() {
            ++references_;
        }

        void Release() {
            if (--references_ == 0)
                delete this;
        }

        virtual Result_ operator()(Args_... args) const = 0;
    };

    template <typename Callable_>
    class Concrete :
        public Abstract
    {
      private:
        Callable_ callable_;

      public:
        Concrete(const Callable_ &callable) :
            callable_(callable)
        {
        }

        virtual Result_ operator()(Args_... args) const {
            return callable_(args...);
        }
    };

  private:
    Abstract *abstract_;

    void Release() {
        if (abstract_ != NULL)
            abstract_->Release();
    }

    void Copy(Abstract *abstract) {
        if (abstract != NULL)
            abstract->Retain();
        Release();
        abstract_ = abstract;
    }

    template <typename Callable_>
    void Assign(const Callable_ &callable) {
        Copy(new Concrete<Callable_>(callable));
    }

  public:
    Function() :
        abstract_(NULL)
    {
    }

    Function(decltype(nullptr)) :
        Function()
    {
    }

    Function(const Function &function) :
        abstract_(function.abstract_)
    {
        abstract_->Retain();
    }

    template <typename Callable_>
    Function(const Callable_ &callable) :
        Function()
    {
        Assign(callable);
    }

    ~Function() {
        Release();
    }

    Function &operator =(decltype(nullptr)) {
        Clear();
        return *this;
    }

    Function &operator =(const Function &function) {
        Copy(function.abstract_);
        return *this;
    }

    Result_ operator()(Args_... args) const {
        return (*abstract_)(args...);
    }

    void Clear() {
        Release();
        abstract_ = NULL;
    }

    template <typename Callable_>
    Function &operator =(const Callable_ &callable) {
        Assign(callable);
        return *this;
    }

    operator bool() const {
        return abstract_ != NULL;
    }
};

#endif//Menes_Function_H
