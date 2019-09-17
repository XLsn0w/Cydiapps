#ifndef PATCHFINDER64_H_
#define PATCHFINDER64_H_

#define CACHED_FIND(type, name) \
type __##name(void);\
type name(void) { \
type cached = 0; \
if (cached == 0) { \
cached = __##name(); \
} \
return cached; \
} \
type __##name(void)

uint64_t find_allproc(void);
uint64_t find_add_x0_x0_0x40_ret(void);
uint64_t find_OSBoolean_True(void);
uint64_t find_OSBoolean_False(void);
uint64_t find_zone_map_ref(void);
uint64_t find_osunserializexml(void);
uint64_t find_smalloc(void);

#endif
