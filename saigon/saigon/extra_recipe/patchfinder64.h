#ifndef PATCHFINDER64_H_
#define PATCHFINDER64_H_

int init_kernel(uint64_t base, const char *filename);
void term_kernel(void);

enum { SearchInCore, SearchInPrelink };

uint64_t find_register_value(uint64_t where, int reg);
uint64_t find_reference(uint64_t to, int n, int prelink);
uint64_t find_strref(const char *string, int n, int prelink);
uint64_t find_gPhysBase(void);
uint64_t find_kernel_pmap(void);
uint64_t find_amfiret(void);
uint64_t find_ret_0(void);
uint64_t find_amfi_memcmpstub(void);
uint64_t find_sbops(void);
uint64_t find_lwvm_mapio_patch(void);
uint64_t find_lwvm_mapio_newj(void);

uint64_t find_entry(void);
const unsigned char *find_mh(void);

uint64_t find_cpacr_write(void);
uint64_t find_str(const char *string);
uint64_t find_amfiops(void);
uint64_t find_sysbootnonce(void);
uint64_t find_trustcache(void);
uint64_t find_amficache(void);

#endif
