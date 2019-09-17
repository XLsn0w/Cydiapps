#include <mach/mach.h>

uint64_t kalloc(vm_size_t size);
void kfree(mach_vm_address_t address, vm_size_t size);

size_t kread(uint64_t where, void *p, size_t size);
uint32_t rk32(uint64_t kaddr);
uint64_t rk64(uint64_t kaddr);

size_t kwrite(uint64_t where, const void *p, size_t size);
void wk32(uint64_t kaddr, uint32_t val);
void wk64(uint64_t kaddr, uint64_t val);

uint64_t zm_fix_addr(uint64_t addr);

int kstrcmp(uint64_t kstr, const char* str);
