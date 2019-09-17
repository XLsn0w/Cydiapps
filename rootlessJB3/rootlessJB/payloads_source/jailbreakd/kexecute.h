#include <mach/mach.h>
#include <inttypes.h>

uint64_t kexecute(uint64_t addr, uint64_t x0, uint64_t x1, uint64_t x2, uint64_t x3, uint64_t x4, uint64_t x5, uint64_t x6);
void init_kexecute(void);
void term_kexecute(void);
