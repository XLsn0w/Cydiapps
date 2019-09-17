#include "kmem.h"
#include "kern_utils.h"
#include "sandbox.h"
#include "patchfinder64.h"
#include "kexecute.h"


typedef uint64_t extension_hdr_t;
typedef uint64_t extension_t;

struct extension_hdr {
/* 0x00 */	extension_hdr_t next;
/* 0x08 */  extension_t ext_lst;
/* 0x10 */	char desc[];
/* 0x18 */
};

struct extension {
    extension_t next;
    uint64_t desc;              // always 0xffffffffffffffff;
    uint8_t something[20];      // all zero
    uint16_t num;               // one
    uint8_t type;               // see ext_type enum
    uint8_t num3;               // one
    uint32_t subtype;           // either 0 or 4 (or whatever unhex gave?..)
    uint32_t num4;              // another number
    void* data;                 // a c string, meaning depends on type and hdr which had this extension
    uint64_t data_len;          // strlen(data)
    uint16_t num5;              // another one!
    uint8_t something_2[14];    // something v2.0
    uint64_t ptr3;              // it's always 0 for files
    uint64_t ptr4;              // idk
};

uint64_t _smalloc(uint64_t size) {
	return kexecute(find_smalloc(), size, 0, 0, 0, 0, 0, 0);
}

uint64_t smalloc(uint64_t size) {
	uint64_t ret = _smalloc(size);
	
	if (ret != 0) {
		// IOAlloc's of small size go to zalloc
		ret = zm_fix_addr(ret);
	}

	return ret;
}

uint64_t sstrdup(const char* s) {
	size_t slen = strlen(s) + 1;

	uint64_t ks = smalloc(slen);
	if (ks) {
		kwrite(ks, s, slen);
	}

	return ks;
}

// Notice: path should *not* end with '/' !
uint64_t extension_create_file(const char* path, uint64_t nextptr) {
    size_t slen = strlen(path);
    
    if (path[slen - 1] == '/') {
        printf("No traling slash in path pls");
        return 0;
    }
    
    uint64_t ext_p = smalloc(sizeof(struct extension));
    uint64_t ks = sstrdup(path);
    
    if (ext_p && ks) {
        struct extension ext;
        bzero(&ext, sizeof(ext));
        ext.next = (extension_t)nextptr;
        ext.desc = 0xffffffffffffffff;
        
        ext.type = 0;
        ext.subtype = 0;
        
        ext.data = (void*)ks;
        ext.data_len = slen;
        
        ext.num = 1;
        ext.num3 = 1;
        
        kwrite(ext_p, &ext, sizeof(ext));
    } else {
        // XXX oh no a leak
    }
    
    return ext_p;
}

int hashing_magic(const char *desc) {
    unsigned int hashed;
    char ch, ch2;
    char *chp;
    
    ch = *desc;
    
    if (*desc) {
        chp = (char *)(desc + 1);
        hashed = 0x1505;
        
        do {
            hashed = 33 * hashed + ch;
            ch2 = *chp++;
            ch = ch2;
        }
        while (ch2);
    }
    else hashed = 0x1505;
    
    return hashed % 9;
}

static const char *ent_key = "com.apple.security.exception.files.absolute-path.read-only";

uint64_t make_ext_hdr(const char* key, uint64_t ext_lst) {
    struct extension_hdr hdr;
    
    uint64_t khdr = smalloc(sizeof(hdr) + strlen(key) + 1);
    
    if (khdr) {
        // we add headers to end
        hdr.next = 0;
        hdr.ext_lst = ext_lst;
        
        kwrite(khdr, &hdr, sizeof(hdr));
        kwrite(khdr + offsetof(struct extension_hdr, desc), key, strlen(key) + 1);
    }
    
    return khdr;
}

void extension_add(uint64_t ext, uint64_t sb, const char* desc) {
    // XXX patchfinder + kexecute would be way better
    
    int slot = hashing_magic(ent_key);
    uint64_t ext_table = rk64(sb + sizeof(void *));
    uint64_t insert_at_p = ext_table + slot * sizeof(void*);
    uint64_t insert_at = rk64(insert_at_p);
    
    while (insert_at != 0) {
        uint64_t kdsc = insert_at + offsetof(struct extension_hdr, desc);
        
        if (kstrcmp(kdsc, desc) == 0) {
            break;
        }
        
        insert_at_p = insert_at;
        insert_at = rk64(insert_at);
    }
    
    if (insert_at == 0) {
        insert_at = make_ext_hdr(ent_key, ext);
        wk64(insert_at_p, insert_at);
    } else {
        // XXX no duplicate check
        uint64_t ext_lst_p = insert_at + offsetof(struct extension_hdr, ext_lst);
        uint64_t ext_lst = rk64(ext_lst_p);
        
        while (ext_lst != 0) {
            printf("ext_lst_p = 0x%llx ext_lst = 0x%llx", ext_lst_p, ext_lst);
            ext_lst_p = ext_lst + offsetof(struct extension, next);
            ext_lst = rk64(ext_lst_p);
        }
        
        printf("ext_lst_p = 0x%llx ext_lst = 0x%llx", ext_lst_p, ext_lst);
        
        wk64(ext_lst_p, ext);
    }
}

// 1 if yes
int has_file_extension(uint64_t sb, const char* path) {
    const char* desc = ent_key;
    int found = 0;
    
    int slot = hashing_magic(ent_key);
    uint64_t ext_table = rk64(sb + sizeof(void *));
    uint64_t insert_at_p = ext_table + slot * sizeof(void*);
    uint64_t insert_at = rk64(insert_at_p);
    
    while (insert_at != 0) {
        uint64_t kdsc = insert_at + offsetof(struct extension_hdr, desc);
        
        if (kstrcmp(kdsc, desc) == 0) {
            break;
        }
        
        insert_at_p = insert_at;
        insert_at = rk64(insert_at);
    }
    
    if (insert_at != 0) {
        uint64_t ext_lst = rk64(insert_at + offsetof(struct extension_hdr, ext_lst));
        
        uint64_t plen = strlen(path);
        char *exist = malloc(plen + 1);
        exist[plen] = '\0';
        
        while (ext_lst != 0) {
            // XXX no type/subtype check
            uint64_t data_len = rk64(ext_lst + offsetof(struct extension, data_len));
            if (data_len == plen) {
                uint64_t data = rk64(ext_lst + offsetof(struct extension, data));
                kread(data, exist, plen);
                
                if (strcmp(path, exist) == 0) {
                    found = 1;
                    break;
                }
            }
            
            ext_lst = rk64(ext_lst);
        }
        
        free(exist);
    }
    
    return found;
}
