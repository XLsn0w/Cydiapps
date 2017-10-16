#ifndef _minibplist16_h
#define _minibplist16_h

#include <stdint.h>

// base type
typedef struct _obp16_object {
  uint32_t type;
}* obp16_object_t;

void
obp16_object_free(
  obp16_object_t obj);

obp16_object_t
obp16_integer_alloc(
  uint64_t value);

obp16_object_t
obp16_null_alloc();

/* doesn't actually need to be NULL terminated */
obp16_object_t
obp16_ascii_string_alloc(
  char* bytes,
  size_t length);

obp16_object_t
obp16_ascii_string_alloc_with_cstring(
  char* str);

obp16_object_t
obp16_dictionary_alloc();

/* 
 * dictionary append takes ownership of the key and value.
 * everything is still mutable until serialization
 */
void
obp16_dictionary_append(
  obp16_object_t obj,
  obp16_object_t key,
  obp16_object_t value);

/* use these to serialize to the full binary format including bplist16 header */
size_t
obp16_full_serialized_size(
  obp16_object_t obj);

/* serialize into provided buffer */
void
obp16_full_serialize_to_buffer(
  obp16_object_t obj,
  void* buffer);

/* allocates a malloced buffer and serializes into it */
void* obp16_full_serialize(
  obp16_object_t obj,
  size_t* out_size);

#endif
