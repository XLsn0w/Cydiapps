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

#ifndef YY_CY_STACK_HH_INCLUDED
#define YY_CY_STACK_HH_INCLUDED

namespace cy {

#if 0
template <class Type_>
class stack {
  public:
    typedef std::vector<Type_> Data_;
    typedef typename Data_::const_reverse_iterator const_iterator;

  private:
    Data_ data_;

  public:
    stack() {
        data_.reserve(200);
    }

    _finline Type_ &operator [](size_t i) {
        return data_[data_.size() - 1 - i];
    }

    _finline const Type_ &operator [](size_t i) const {
        return data_[data_.size() - 1 - i];
    }

    _finline void push(Type_ &t) {
        data_.push_back(t);
    }

    _finline void pop() {
        data_.pop_back();
    }

    _finline void pop(unsigned int size) {
        for (; size != 0; --size)
            pop();
    }

    void clear() {
        data_.clear();
    }

    _finline size_t size() const {
        return data_.size();
    }

    _finline const_iterator begin() const {
        return data_.rbegin();
    }

    _finline const_iterator end() const {
        return data_.rend();
    }

  private:
    stack(const stack &);
    stack &operator =(const stack &);
};
#else
template <class Type_>
class stack {
  public:
    typedef std::reverse_iterator<Type_ *> const_iterator;

  private:
    Type_ *begin_;
    Type_ *end_;
    Type_ *capacity_;

    void destroy() {
        for (Type_ *i(begin_); i != end_; ++i)
            i->~Type_();
    }

    void reserve() {
        size_t capacity(capacity_ - begin_);
        if (capacity == 0)
            capacity = 200;
        else
            capacity *= 2;

        Type_ *data(static_cast<Type_ *>(::operator new(sizeof(Type_) * capacity)));

        size_t size(end_ - begin_);
        for (size_t i(0); i != size; ++i) {
            Type_ &old(begin_[i]);
            new (data + i) Type_(old);
            old.~Type_();
        }

        ::operator delete(begin_);

        begin_ = data;
        end_ = data + size;
        capacity_ = data + capacity;
    }

  public:
    stack() :
        begin_(NULL),
        end_(NULL),
        capacity_(NULL)
    {
        reserve();
    }

    ~stack() {
        destroy();
        ::operator delete(begin_);
    }

    _finline Type_ &operator [](size_t i) {
        return end_[-1 - i];
    }

    _finline const Type_ &operator [](size_t i) const {
        return end_[-1 - i];
    }

    _finline void push(Type_ &t) {
        if (end_ == capacity_)
            reserve();
        new (end_++) Type_(t);
    }

    _finline void pop() {
        (--end_)->~Type_();
    }

    _finline void pop(unsigned int size) {
        for (; size != 0; --size)
            pop();
    }

    void clear() {
        destroy();
        end_ = begin_;
    }

    _finline size_t size() const {
        return end_ - begin_;
    }

    _finline const_iterator begin() const {
        return const_iterator(end_);
    }

    _finline const_iterator end() const {
        return const_iterator(begin_);
    }

  private:
    stack(const stack &);
    stack &operator =(const stack &);
};
#endif

template <class Type_, class Stack_ = stack<Type_> >
class slice {
  public:
    slice(const Stack_ &stack, unsigned int range) :
        stack_(stack),
        range_(range)
    {
    }

    _finline const Type_ &operator [](unsigned int i) const {
        return stack_[range_ - i];
    }

  private:
    const Stack_ &stack_;
    unsigned int range_;
};

}

#endif/*YY_CY_STACK_HH_INCLUDED*/
