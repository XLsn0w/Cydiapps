#include <sys/types.h>

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
    uint64_t kernel_base;
};

int getOffsetsFromFile(char *file, struct offsets *off);
