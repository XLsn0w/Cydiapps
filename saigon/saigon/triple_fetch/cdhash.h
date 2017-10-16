#ifndef cdhash_h
#define cdhash_h

#include <mach/mach.h>
#include <stdint.h>

#include <CommonCrypto/CommonDigest.h>

#define AMFID_HASH_SIZE CC_SHA1_DIGEST_LENGTH

void get_hash_for_amfid(mach_port_t amfid_task_port, char* path, uint64_t universal_file_offset, uint8_t* hash_buf);

void*
fakesign(void* code,
         uint32_t code_size,
         char* identifier,       // NULL-terminated identifier string
         int is_platform_binary, // are we going to get loaded into a platform binary?
         char* teamid,           // if the target has a teamid (non-platform binary), what is it? (NULL-terminated string)
         uint32_t* blob_size);

#endif /* cdhash_h */
