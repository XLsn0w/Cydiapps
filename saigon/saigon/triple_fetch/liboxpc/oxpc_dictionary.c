#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "oxpc_utils.h"

#include "oxpc_object.h"
#include "oxpc_dictionary.h"

// runtime structure
typedef struct _oxpc_dictionary {
  uint32_t type;
  uint32_t count;
  size_t serialized_size;
  char** keys;
  oxpc_object_t* values;
}* oxpc_dictionary_t;

// runtime structure allocation
oxpc_object_t
oxpc_dictionary_alloc()
{
  oxpc_dictionary_t dict = NULL;
  dict = malloc(sizeof(*dict));
  if (!dict) {
    ERROR("unable to allocate memory for oxpc_dictionary");
  }
  dict->type = OXPC_TYPE_DICTIONARY;
  dict->count = 0;
  dict->serialized_size = 0;
  dict->keys = NULL;
  dict->values = NULL;
  return (oxpc_object_t)dict;
}

/*
 * oxpc_dictiomary_append takes ownership of value
 * callers of this function must no longer use value
 *
 * the dictionary is only mutable until it's serialized
 * after serialization it may not be modified
 */

void
oxpc_dictionary_append(
  oxpc_object_t obj,
  char* key,
  oxpc_object_t value)
{
  oxpc_check_type(obj, OXPC_TYPE_DICTIONARY);
  oxpc_dictionary_t dict = (oxpc_dictionary_t)obj;

  if (dict->count > oxpc_arbitrary_size_limit) {
    ERROR("oxpc dictionary grew too large");
  }

  dict->count++;
  size_t new_keys_size = dict->count * sizeof(char*);
  dict->keys = realloc(dict->keys, new_keys_size);
  if (!dict->keys) {
    ERROR("oxpc_dictionary keys reallocation failed\n");
  }
 
  size_t new_values_size = dict->count * sizeof(oxpc_object_t*);
  dict->values = realloc(dict->values, new_values_size);
  if (!dict->values) {
    ERROR("oxpc_dictionary values reallocation failed\n");
  }

  dict->keys[dict->count-1] = strdup(key);
  dict->values[dict->count-1] = value;
}

// runtime structure free
static void
oxpc_dictionary_free(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_DICTIONARY);
  oxpc_dictionary_t dict = (oxpc_dictionary_t)obj;

  for (int i = 0; i < dict->count; i++) {
    free(dict->keys[i]);
    oxpc_object_free(dict->values[i]);
  }

  free(dict->keys);
  free(dict->values);

  free(dict);
}

typedef struct __attribute__((packed)) _oxpc_dictionary_serialized {
  uint32_t type;
  uint32_t byte_count; // size in bytes from the first byte of count (so after byte_count)
  uint32_t count; // number of key/value pairs
  uint8_t bytes[0];
}* oxpc_dictionary_serialized_t;

// size of serialized structure
static size_t
oxpc_dictionary_serialized_size(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_DICTIONARY);
  oxpc_dictionary_t dict = (oxpc_dictionary_t)obj;

  if (dict->serialized_size != 0) {
    return dict->serialized_size;
  }

  size_t total = 0;
  for (uint32_t i = 0; i < dict->count; i++) {
    size_t key_size = round_up_32((uint32_t)(strlen(dict->keys[i]) + 1), 4);
    size_t value_size = oxpc_object_serialized_size(dict->values[i]);

    if (key_size > oxpc_arbitrary_size_limit) {
      ERROR("dictionary key too large for serialization");
    }
    if (value_size > oxpc_arbitrary_size_limit) {
      ERROR("dictionary value too large for serialization");
    }
    if (total > oxpc_arbitrary_size_limit) {
      ERROR("dictionary too large for serialization");
    }
    total += key_size + value_size;
  }
  dict->serialized_size = sizeof(struct _oxpc_dictionary_serialized) + total;
  return dict->serialized_size;
}

// serialize runtime object to buffer
static void
oxpc_dictionary_serialize_to_buffer(
  oxpc_object_t obj,
  void* buffer,
  oxpc_port_list_t ports)
{
  oxpc_check_type(obj, OXPC_TYPE_DICTIONARY);
  oxpc_dictionary_t dict = (oxpc_dictionary_t)obj;

  oxpc_dictionary_serialized_t serialized_dict = (oxpc_dictionary_serialized_t)buffer;
  serialized_dict->type = dict->type;
  serialized_dict->byte_count = (uint32_t)(oxpc_dictionary_serialized_size(obj) - 8);
  serialized_dict->count = dict->count;

  uint8_t* dict_buffer = serialized_dict->bytes;

  for (uint32_t i = 0; i < dict->count; i++) {
    size_t key_size = strlen(dict->keys[i]) + 1;
    memcpy(dict_buffer, dict->keys[i], key_size);
    // maintain alignment:
    key_size = round_up_32((uint32_t)key_size, 4);
    dict_buffer += key_size;

    size_t value_size = oxpc_object_serialized_size(dict->values[i]);
    oxpc_object_serialize_to_buffer(dict->values[i], dict_buffer, ports);
    dict_buffer += value_size;
  }
}

struct oxpc_type_descriptor oxpc_dictionary_type_descriptor = {
  .free = oxpc_dictionary_free,
  .serialized_size = oxpc_dictionary_serialized_size,
  .serialize_to_buffer = oxpc_dictionary_serialize_to_buffer,
};
