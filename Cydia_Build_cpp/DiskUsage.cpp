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

#include <fcntl.h>
#include <dirent.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/stat.h>

#define _syscall(expr) ({ decltype(expr) _value; for (;;) { \
    _value = (expr); \
    if ((long) _value != -1) \
        break; \
    if (errno != EINTR) { \
        perror(#expr); \
        return -1; \
    } \
} _value; })

extern "C" int __getdirentries64(int, char *, int, long *);

enum Recurse {
    RecurseYes,
    RecurseNo,
    RecurseMaybe,
};

struct File {
    int fd_;

    File(int fd);
    ~File();

    operator int() const;
};

File::File(int fd) :
    fd_(fd)
{
}

File::~File() {
    close(fd_);
}

File::operator int() const {
    return fd_;
}

static bool DiskUsage(size_t &total, const char *path, size_t before, Recurse recurse) {
    File fd(_syscall(open_dprotected_np(path, O_RDONLY | O_SYMLINK, 0, O_DP_GETRAWENCRYPTED)));

    struct stat stat;
    _syscall(fstat(fd, &stat));
    total += stat.st_blocks * 512;

    if (recurse == RecurseMaybe)
        switch (stat.st_mode & S_IFMT) {
            case S_IFLNK:
                return true;
            default:
                return false;

            case S_IFDIR:
                recurse = RecurseYes;
                break;
            case S_IFREG:
                recurse = RecurseNo;
                break;
        }

    if (recurse == RecurseNo) {
    } else for (long address(0);;) {
        char buffer[4096];
        int size(_syscall(__getdirentries64(fd, buffer, sizeof(buffer), &address)));
        if (size == 0)
            break;

        const char *next(buffer), *stop(next + size);
        while (next != stop) {
            const dirent *dir(reinterpret_cast<const dirent *>(next));
            const char *name(dir->d_name);
            size_t after(strlen(name));

            if (dir->d_ino == 0);
            else if (after == 1 && name[0] == '.');
            else if (after == 2 && name[0] == '.' && name[1] == '.');
            else {
                size_t both(before + 1 + after);
                char sub[both + 1];
                memcpy(sub, path, before);
                sub[before] = '/';
                memcpy(sub + before + 1, name, after);
                sub[both] = '\0';

                switch (dir->d_type) {
                    case DT_DIR:
                        if (!DiskUsage(total, sub, both, RecurseYes))
                            return false;
                        break;

                    case DT_LNK:
                    case DT_REG:
                        if (!DiskUsage(total, sub, both, RecurseNo))
                            return false;
                        break;

                    default:
                        return false;
                }
            }

            next += dir->d_reclen;
        }
    }

    return true;
}

ssize_t DiskUsage(const char *path) {
    size_t total(0);
    if (!DiskUsage(total, path, strlen(path), RecurseMaybe))
        return -1;
    return total;
}
