#import "kern_utils.h"
#import "patchfinder64.h"
#import "kmem.h"

#define MAX_CHUNK_SIZE 0xFFF

size_t kread(uint64_t where, void *p, size_t size) {
	int rv;
	size_t offset = 0;
	while (offset < size) {
		mach_vm_size_t sz, chunk = MAX_CHUNK_SIZE;
		if (chunk > size - offset) {
			chunk = size - offset;
		}
		rv = mach_vm_read_overwrite(tfpzero, where + offset, chunk, (mach_vm_address_t)p + offset, &sz);
		if (rv || sz == 0) {
			fprintf(stderr, "[e] error reading kernel @%p\n", (void *)(offset + where));
			break;
		}
		offset += sz;
	}
	return offset;
}

size_t kwrite(uint64_t where, const void *p, size_t size) {
	int rv;
	size_t offset = 0;
	while (offset < size) {
		size_t chunk = MAX_CHUNK_SIZE;
		if (chunk > size - offset) {
			chunk = size - offset;
		}
		rv = mach_vm_write(tfpzero, where + offset, (mach_vm_offset_t)p + offset, chunk);
		if (rv) {
			fprintf(stderr, "[e] error writing kernel @%p\n", (void *)(offset + where));
			break;
		}
		offset += chunk;
	}
	return offset;
}

uint64_t kalloc(vm_size_t size){
	mach_vm_address_t address = 0;
	mach_vm_allocate(tfpzero, (mach_vm_address_t *)&address, size, VM_FLAGS_ANYWHERE);
	return address;
}

void kfree(mach_vm_address_t address, vm_size_t size){
  mach_vm_deallocate(tfpzero, address, size);
}

uint32_t rk32(uint64_t kaddr) {
  uint32_t val = 0;
  kread(kaddr, &val, sizeof(val));
  return val;
}

uint64_t rk64(uint64_t kaddr) {
  uint64_t val = 0;
  kread(kaddr, &val, sizeof(val));
  return val;
}

void wk32(uint64_t kaddr, uint32_t val) {
  kwrite(kaddr, &val, sizeof(val));
}

void wk64(uint64_t kaddr, uint64_t val) {
  kwrite(kaddr, &val, sizeof(val));
}

// thx Siguza
typedef struct {
  uint64_t prev;
  uint64_t next;
  uint64_t start;
  uint64_t end;
} kmap_hdr_t;

uint64_t zm_fix_addr(uint64_t addr) {
  static kmap_hdr_t zm_hdr = {0, 0, 0, 0};

  if (zm_hdr.start == 0) {
	// xxx rk64(0) ?!
	uint64_t zone_map = rk64(find_zone_map_ref());
	// hdr is at offset 0x10, mutexes at start
	size_t r = kread(zone_map + 0x10, &zm_hdr, sizeof(zm_hdr));
	printf("zm_range: 0x%llx - 0x%llx (read 0x%zx, exp 0x%zx)\n", zm_hdr.start, zm_hdr.end, r, sizeof(zm_hdr));

	if (r != sizeof(zm_hdr) || zm_hdr.start == 0 || zm_hdr.end == 0) {
	  printf("kread of zone_map failed!\n");
	  exit(1);
	}

	if (zm_hdr.end - zm_hdr.start > 0x100000000) {
		printf("zone_map is too big, sorry.\n");
		exit(1);
	}
  }

  uint64_t zm_tmp = (zm_hdr.start & 0xffffffff00000000) | ((addr) & 0xffffffff);

  return zm_tmp < zm_hdr.start ? zm_tmp + 0x100000000 : zm_tmp;
}

int kstrcmp(uint64_t kstr, const char* str) {
	// XXX be safer, dont just assume you wont cause any
	// page faults by this
	size_t len = strlen(str) + 1;
	char *local = malloc(len + 1);
	local[len] = '\0';

	int ret = 1;

	if (kread(kstr, local, len) == len) {
		ret = strcmp(local, str);
	}

	free(local);

	return ret;
}
