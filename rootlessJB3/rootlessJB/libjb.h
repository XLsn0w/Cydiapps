#include <sys/time.h>

#ifndef libjb_h_included
#define libjb_h_included



/* libhfs *******************************************************************/

enum {
    kPermOtherExecute  = 1 << 0,
    kPermOtherWrite    = 1 << 1,
    kPermOtherRead     = 1 << 2,
    kPermGroupExecute  = 1 << 3,
    kPermGroupWrite    = 1 << 4,
    kPermGroupRead     = 1 << 5,
    kPermOwnerExecute  = 1 << 6,
    kPermOwnerWrite    = 1 << 7,
    kPermOwnerRead     = 1 << 8,
    kPermMask          = 0x1FF,
    kOwnerNotRoot      = 1 << 9,
    kFileTypeUnknown   = 0x0 << 16,
    kFileTypeFlat      = 0x1 << 16,
    kFileTypeDirectory = 0x2 << 16,
    kFileTypeLink      = 0x3 << 16,
    kFileTypeMask      = 0x3 << 16
};

typedef long CICell;

extern char *gLoadAddr; /* buffer of size 32MB (max file size) */

CICell HFSOpen(const char *filename, long offset);
long HFSReadFile(CICell ih, char *filePath, void *base, unsigned long offset, unsigned long length);
long HFSGetDirEntry(CICell ih, char *dirPath, unsigned long *dirIndex, char **name, long *flags, long *time);
void HFSClose(CICell);

/* untar ********************************************************************/

/* untar 'a' to current directory.  path is name of archive (informational) */
void untar(FILE *a, const char *path);

/* launchctl ****************************************************************/

int launchctl_load_cmd(const char *filename, int do_load, int opt_force, int opt_write);

/* hashes *******************************************************************/

struct trust_dsk {
    unsigned int version;
    unsigned char uuid[16];
    unsigned int count;
    //unsigned char data[];
} __attribute__((packed));

struct trust_mem {
    uint64_t next; //struct trust_mem *next;
    unsigned char uuid[16];
    unsigned int count;
    //unsigned char data[];
} __attribute__((packed));

struct hash_entry_t {
    uint16_t num;
    uint16_t start;
} __attribute__((packed));

typedef uint8_t hash_t[20];

extern hash_t *allhash;
extern unsigned numhash;
extern struct hash_entry_t *amfitab;
extern hash_t *allkern;

/* can be called multiple times. kernel read func & amfi/top trust chain block are optional */
int grab_hashes(const char *root, size_t (*kread)(uint64_t, void *, size_t), uint64_t amfi, uint64_t top);

#endif
