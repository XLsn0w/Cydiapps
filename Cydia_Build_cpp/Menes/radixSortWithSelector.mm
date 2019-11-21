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

#include "CyteKit/UCPlatform.h"

#include "Menes/radixSortWithSelector.h"

#include <objc/runtime.h>

struct RadixItem_ {
    size_t index;
    uint32_t key;
};

static RadixItem_ *CYRadixSort(struct RadixItem_ *swap, size_t count) {
    struct RadixItem_ *lhs(swap), *rhs(swap + count);

    static const size_t width = 32;
    static const size_t bits = 11;
    static const size_t slots = 1 << bits;
    static const size_t passes = (width + (bits - 1)) / bits;

    size_t *hist(new size_t[slots]);

    for (size_t pass(0); pass != passes; ++pass) {
        memset(hist, 0, sizeof(size_t) * slots);

        for (size_t i(0); i != count; ++i) {
            uint32_t key(lhs[i].key);
            key >>= pass * bits;
            key &= _not(uint32_t) >> width - bits;
            ++hist[key];
        }

        size_t offset(0);
        for (size_t i(0); i != slots; ++i) {
            size_t local(offset);
            offset += hist[i];
            hist[i] = local;
        }

        for (size_t i(0); i != count; ++i) {
            uint32_t key(lhs[i].key);
            key >>= pass * bits;
            key &= _not(uint32_t) >> width - bits;
            rhs[hist[key]++] = lhs[i];
        }

        RadixItem_ *tmp(lhs);
        lhs = rhs;
        rhs = tmp;
    }

    delete [] hist;
    return lhs;
}

void CYRadixSortUsingFunction(id *self, size_t count, MenesRadixSortFunction function, void *argument) {
    struct RadixItem_ *swap(new RadixItem_[count * 2]);

    for (size_t i(0); i != count; ++i) {
        RadixItem_ &item(swap[i]);
        item.index = i;
        item.key = function(self[i], argument);
    }

    auto lhs(CYRadixSort(swap, count));

    const void **values(new const void *[count]);
    for (size_t i(0); i != count; ++i)
        values[i] = self[lhs[i].index];
    memcpy(self, values, count * sizeof(id));
    delete [] values;

    delete [] swap;
}

@implementation NSMutableArray (MenesRadixSortWithSelector)

- (void) radixSortUsingFunction:(MenesRadixSortFunction)function withContext:(void *)argument {
    size_t count([self count]);
    struct RadixItem_ *swap(new RadixItem_[count * 2]);

    for (size_t i(0); i != count; ++i) {
        RadixItem_ &item(swap[i]);
        item.index = i;
        item.key = function([self objectAtIndex:i], argument);
    }

    auto lhs(CYRadixSort(swap, count));

    const void **values(new const void *[count]);
    for (size_t i(0); i != count; ++i)
        values[i] = [self objectAtIndex:lhs[i].index];
    CFArrayReplaceValues((CFMutableArrayRef) self, CFRangeMake(0, count), values, count);
    delete [] values;

    delete [] swap;
}

- (void) radixSortUsingSelector:(SEL)selector {
    if ([self count] == 0)
        return;

    IMP imp(class_getMethodImplementation([[self lastObject] class], selector));
    [self radixSortUsingFunction:reinterpret_cast<MenesRadixSortFunction>(imp) withContext:selector];
}

@end
