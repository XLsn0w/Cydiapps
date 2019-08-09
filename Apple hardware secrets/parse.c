#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/stat.h>

#define APRR0_MAX 0x4545010167670101
#define APRR1_MAX 0x4455445566666677

#define AP_UXN              0x1
#define AP_PXN              0x2
#define AP_UL               0x4
#define AP_RO               0x8

static void prot(uint64_t p)
{
    char pr = 'r',
         pw = (p & AP_RO)  ? '-' : 'w',
         px = (p & AP_PXN) ? '-' : 'x',
         ur = (p & AP_UL)  ? pr  : '-',
         uw = (p & AP_UL)  ? pw  : '-',
         ux = (p & AP_UXN) ? '-' : 'x';
    printf("%c%c%c/%c%c%c", pr, pw, px, ur, uw, ux);
}

static void hpd(uint64_t p)
{
    char pr = 'r',
         pw = (p & AP_RO)  ? '-' : 'w',
         px = (p & AP_PXN) ? '-' : 'x',
         ur = (p & AP_UL)  ? '-' : pr,
         uw = (p & AP_UL)  ? '-' : pw,
         ux = (p & AP_UXN) ? '-' : 'x';
    printf("%c%c%c/%c%c%c", pr, pw, px, ur, uw, ux);
}

static void aprr(uint64_t uval, uint64_t pval, uint64_t i)
{
    uint64_t p = pval >> (i << 2),
             u = uval >> (i << 2);
    char pr = (p & 0x4) ? 'r' : '-',
         pw = (p & 0x2) ? 'w' : '-',
         px = (p & 0x1) ? 'x' : '-',
         ur = (u & 0x4) ? 'r' : '-',
         uw = (u & 0x2) ? 'w' : '-',
         ux = (u & 0x1) ? 'x' : '-';
    printf("%c%c%c/%c%c%c", pr, pw, px, ur, uw, ux);
}

#define PAR_PRINT_ADDR 0
#if PAR_PRINT_ADDR
#   define STR "%-18s "
#else
#   define STR "%-4s "
#endif

int main(int argc, const char **argv)
{
    if(argc != 3 && argc != 5)
    {
        fprintf(stderr, "Usage: %s file offset mask0 mask1\n", argv[0]);
        return -1;
    }
    uint64_t off = strtoull(argv[2], NULL, 0);
    uint64_t aprr0 = argc == 5 ? strtoull(argv[3], NULL, 0) : 0xffffffffffffffffULL;
    uint64_t aprr1 = argc == 5 ? strtoull(argv[4], NULL, 0) : 0xffffffffffffffffULL;
    aprr0 &= APRR0_MAX;
    aprr1 &= APRR1_MAX;
    int fd = open(argv[1], O_RDONLY);
    if(fd == -1)
    {
        fprintf(stderr, "Failed to open file\n");
        return -1;
    }
    struct stat s;
    fstat(fd, &s);
    if(off >= s.st_size || (s.st_size - off) < 0x4c00)
    {
        fprintf(stderr, "Bad off/size\n");
        return -1;
    }
    void *addr = mmap(NULL, s.st_size, PROT_READ, MAP_FILE | MAP_PRIVATE, fd, 0);
    uintptr_t p = (uintptr_t)addr + off;

    printf(STR STR STR STR "KRN/USR (HPD/HPD) APRR\n", "EL1R", "EL1W", "EL0R", "EL0W");
    uint64_t *u = (uint64_t*)p;
    for(size_t i = 0; i < 0x10; ++i)
    {
        for(size_t j = 0; j < 0x10; ++j)
        {
            for(size_t k = 0; k < 0x8; k += 2)
            {
                uint64_t ok  = u[(i * 0x10 + j) * 8 + k],
                         val = u[(i * 0x10 + j) * 8 + k + 1];
                if(ok != 0x1)
                {
                    printf(STR, "ERR");
                }
                else if(val & 0x1)
                {
#if PAR_PRINT_ADDR
                    printf("------------------ ");
#else
                    printf("---- ");
#endif
                }
                else
                {
#if PAR_PRINT_ADDR
                    printf("0x%016llx ", val & 0x0000fffffffff000);
#else
                    printf("okok ");
#endif
                }
            }
            prot(j);
            printf(" (");
            hpd(i);
            printf(") ");
            aprr(aprr0, aprr1, j);
            printf("\n");
        }
    }

    printf("\n");
    printf("[ACTUAL]  TTE     (HPD)     APRR\n");
    uint8_t *a = (uint8_t*)(p + 0x4000);
    uint8_t *b = (uint8_t*)(p + 0x4600);
    for(size_t i = 0; i < 0x10; ++i)
    {
        for(size_t j = 0; j < 0x10; ++j)
        {
            char pr = a[(i * 0x10 + j) * 6 + 0] != 0x1 ? '-' : a[(i * 0x10 + j) * 6 + 1] != 0x42 ? '#' : 'r',
                 pw = a[(i * 0x10 + j) * 6 + 2] != 0x1 ? '-' : a[(i * 0x10 + j) * 6 + 3] != 0xaa ? '#' : 'w',
                 px = a[(i * 0x10 + j) * 6 + 4] != 0x1 ? '-' : a[(i * 0x10 + j) * 6 + 5] != 0x69 ? '#' : 'x',
                 ur = b[(i * 0x10 + j) * 6 + 0] != 0x1 ? '-' : b[(i * 0x10 + j) * 6 + 1] != 0x42 ? '#' : 'r',
                 uw = b[(i * 0x10 + j) * 6 + 2] != 0x1 ? '-' : b[(i * 0x10 + j) * 6 + 3] != 0xaa ? '#' : 'w',
                 ux = b[(i * 0x10 + j) * 6 + 4] != 0x1 ? '-' : b[(i * 0x10 + j) * 6 + 5] != 0x69 ? '#' : 'x';
            printf("[%c%c%c/%c%c%c] ", pr, pw, px, ur, uw, ux);
            prot(j);
            printf(" (");
            hpd(i);
            printf(") ");
            aprr(aprr0, aprr1, j);
            printf("\n");
        }
    }

    return 0;
}
