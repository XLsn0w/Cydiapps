#include <assert.h>
#include <stdint.h>
#include <string.h>
#include "patchfinder64.h"
#include "offsets.h"

extern struct offsets off;

uint64_t find_add_x0_x0_0x40_ret() {
    return off.gadget;
}

uint64_t find_allproc() {
    return off.allproc;
}

uint64_t find_OSBoolean_True() {
    return off.OSBooleanTrue;
}

uint64_t find_OSBoolean_False() {
    return off.OSBooleanFalse;
}

uint64_t find_zone_map_ref() {
    return off.zone_map_ref;
}

uint64_t find_osunserializexml() {
    return off.OSUnserializeXML;
}

uint64_t find_smalloc() {
    return off.smalloc;
}
