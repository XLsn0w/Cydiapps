// Copyright Notice (GNU Affero GPL) {{{
/* Cyndir - (Awesome) Memory Mapped Dictionary
 * Copyright (C) 2010  Jay Freeman (saurik)
*/

/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
// }}}

#ifndef CYTORE_HPP
#define CYTORE_HPP

#include <fcntl.h>

#include <sys/mman.h>
#include <sys/stat.h>

#include <cstdio>
#include <cstdlib>

#include <errno.h>
#include <stdint.h>
#include <unistd.h>

#define _assert(test) do \
    if (!(test)) { \
        fprintf(stderr, "_assert(%d:%s)@%s:%u[%s]\n", errno, #test, __FILE__, __LINE__, __FUNCTION__); \
        exit(-1); \
    } \
while (false)

namespace Cytore {

static const uint32_t Magic = 'cynd';

struct Header {
    uint32_t magic_;
    uint32_t version_;
    uint32_t size_;
    uint32_t reserved_;
} _packed;

template <typename Target_>
class Offset {
  private:
    uint32_t offset_;

  public:
    Offset() :
        offset_(0)
    {
    }

    Offset(uint32_t offset) :
        offset_(offset)
    {
    }

    Offset &operator =(uint32_t offset) {
        offset_ = offset;
        return *this;
    }

    uint32_t GetOffset() const {
        return offset_;
    }

    bool IsNull() const {
        return offset_ == 0;
    }
} _packed;

struct Block {
    Cytore::Offset<void> reserved_;
} _packed;

template <typename Type_>
static _finline Type_ Round(Type_ value, Type_ size) {
    Type_ mask(size - 1);
    return value + mask & ~mask;
}

template <typename Base_>
class File {
  private:
    static const unsigned Shift_ = 17;
    static const size_t Block_ = 1 << Shift_;
    static const size_t Mask_ = Block_ - 1;

  private:
    int file_;

    typedef std::vector<uint8_t *> BlockVector_;
    BlockVector_ blocks_;

    struct Mapping_ {
        uint8_t *data_;
        size_t size_;

        Mapping_(uint8_t *data, size_t size) :
            data_(data),
            size_(size)
        {
        }
    };

    typedef std::vector<Mapping_> MappingVector_;
    MappingVector_ maps_;

    Header &Header_() {
        return *reinterpret_cast<Header *>(blocks_[0]);
    }

    uint32_t &Size_() {
        return Header_().size_;
    }

    void Map_(size_t size) {
        size_t before(blocks_.size() * Block_);
        size_t extend(size - before);

        void *data(mmap(NULL, extend, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, file_, before));
        _assert(data != MAP_FAILED);
        uint8_t *bytes(reinterpret_cast<uint8_t *>(data));

        maps_.push_back(Mapping_(bytes, extend));
        for (size_t i(0); i != extend >> Shift_; ++i)
            blocks_.push_back(bytes + Block_ * i);
    }

    bool Truncate_(size_t capacity) {
        capacity = Round(capacity, Block_);

        int error(ftruncate(file_, capacity));
        if (error != 0)
            return false;

        Map_(capacity);
        return true;
    }

  public:
    File() :
        file_(-1)
    {
    }

    File(const char *path) :
        file_(-1)
    {
        Open(path);
    }

    ~File() {
        for (typename MappingVector_::const_iterator map(maps_.begin()); map != maps_.end(); ++map)
            munmap(map->data_, map->size_);
        close(file_);
    }

    void Sync() {
        for (typename MappingVector_::const_iterator map(maps_.begin()); map != maps_.end(); ++map)
            msync(map->data_, map->size_, MS_SYNC);
    }

    size_t Capacity() const {
        return blocks_.size() * Block_;
    }

    void Open(const char *path) { open:
        _assert(file_ == -1);
        file_ = open(path, O_RDWR | O_CREAT | O_EXLOCK, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
        _assert(file_ != -1);

        struct stat stat;
        _assert(fstat(file_, &stat) == 0);

        size_t core(sizeof(Header) + sizeof(Base_));

        size_t size(stat.st_size);
        if (size == 0) {
            if (!Truncate_(core)) {
                unlink(path);
                _assert(false);
            }

            Header_().magic_ = Magic;
            Size_() = core;
        } else if (size < core) {
            close(file_);
            file_ = -1;
            unlink(path);
            goto open;
        } else {
            // XXX: this involves an unneccessary call to ftruncate()
            _assert(Truncate_(size));
            _assert(Header_().magic_ == Magic);
            _assert(Header_().version_ == 0);
        }
    }

    bool Reserve(size_t capacity) {
        if (capacity <= Capacity())
            return true;

        uint8_t *block(blocks_.back());
        blocks_.pop_back();

        if (Truncate_(capacity))
            return true;
        else {
            blocks_.push_back(block);
            return false;
        }
    }

    template <typename Target_>
    Target_ &Get(uint32_t offset) {
        return *reinterpret_cast<Target_ *>(offset == 0 ? NULL : blocks_[offset >> Shift_] + (offset & Mask_));
    }

    template <typename Target_>
    Target_ &Get(Offset<Target_> &ref) {
        return Get<Target_>(ref.GetOffset());
    }

    Base_ *operator ->() {
        return &Get<Base_>(sizeof(Header));
    }

    template <typename Target_>
    Offset<Target_> New(size_t extra = 0) {
        size_t size(sizeof(Target_) + extra);
        size = Round(size, sizeof(uintptr_t));

        uint32_t offset;
        if (!Reserve(Size_() + size))
            offset = 0;
        else {
            offset = Size_();
            Size_() += size;
        }

        return Offset<Target_>(offset);
    }
};

}

#endif//CYTORE_HPP
