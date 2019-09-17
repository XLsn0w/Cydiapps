//
//  offsetsDump.h
//  rootlessJB
//
//  Created by Jake James on 8/29/18.
//  Copyright © 2018 Jake James. All rights reserved.
//

#ifndef offsetsDump_h
#define offsetsDump_h

#include <stdio.h>

struct offsets {
    uint64_t allproc;
    uint64_t OSBooleanTrue;
    uint64_t OSBooleanFalse;
    uint64_t gadget;
    uint64_t zone_map_ref;
    uint64_t OSUnserializeXML;
    uint64_t smalloc;
    uint64_t vnode_lookup;
    uint64_t vfs_context;
    uint64_t vnode_put;
    uint64_t kernelbase;
    uint64_t trustcache;
};

int dumpOffsetsToFile(char *file);

#endif /* offsetsDump_h */
