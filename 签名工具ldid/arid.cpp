#include <iostream>
#include <string.h>
#include "minimal/mapping.h"

struct ar_hdr {
    char ar_name[16];
    char ar_date[12];
    char ar_uid[6];
    char ar_gid[6];
    char ar_mode[8];
    char ar_size[10];
#define	ARFMAG "`\n"
    char ar_fmag[2];
};

int main(int argc, char *argv[]) {
    size_t size;
    _assert(argc == 2);
    uint8_t *data = reinterpret_cast<uint8_t *>(map(argv[1], 0, _not(size_t), &size, false));
    data += 8;
    uint8_t *end = data + size;
    while (end - data >= sizeof(struct ar_hdr)) {
        struct ar_hdr *head = reinterpret_cast<struct ar_hdr *>(data);
        memset(head->ar_date + 1, ' ', sizeof(head->ar_date) - 1);
        head->ar_date[0] = '0';
        size_t length = strtoul(head->ar_size, NULL, 10);
        data += length + sizeof(struct ar_hdr);
    }
    return 0;
}
