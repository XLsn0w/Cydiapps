#include "offsets.h"
#include <sys/fcntl.h>
#include <unistd.h>
#include <stdio.h>

int getOffsetsFromFile(char *file, struct offsets *off) {
    FILE *f = fopen(file, "rb");
    if (!f) return -1;
    fread(off, sizeof(struct offsets), 1, f);
    fclose(f);
    return !(off->allproc);
}
